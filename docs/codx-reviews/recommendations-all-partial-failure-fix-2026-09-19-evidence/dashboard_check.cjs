// Extended from Task 13's real-handler Node VM test: now includes real cache,
// reload initializer, tab handlers, thumbnail and filter functions.
const fs=require('fs'),vm=require('vm'),path=require('path'),assert=require('assert');
const E=__dirname,root=path.resolve(E,'../../..');
const old=fs.readFileSync(path.join(E,'before/app/dashboard.html'),'utf8');
const now=fs.readFileSync(path.join(root,'app/dashboard.html'),'utf8');
const clone=x=>JSON.parse(JSON.stringify(x));
function handler(text){const start=text.indexOf("document.getElementById('get-recs-btn').addEventListener");const end=text.indexOf('\n});',start)+5;assert(start>=0&&end>start);return text.slice(start,end);}
function func(text,name){const match=new RegExp('(?:async )?function '+name+'\\(').exec(text);assert(match,name);return text.slice(match.index,text.indexOf('\n}',match.index)+2);}
async function setup(source,version,{failed=[],selected='fantasy',store=new Map(),filtered=false,network=false,status=null,empty=false,user='fixture'}={}){
 const elements={'loading':{style:{}},'results-area':{innerHTML:''},'audiobook-filter':{value:filtered?'any':''},'series-status-filter':{value:filtered?'completed_only':''}};
 const callbacks={},calls=[],renders=[],queries=[];
 const buttons=['','fantasy','sci_fi'].map(genre=>({dataset:{genre},classList:{toggle(){},add(){},remove(){}},addEventListener(_,fn){this.click=fn;}}));
 let fail=failed,offline=network;
 const lists=Object.fromEntries(['','fantasy','sci_fi'].map(g=>[g,empty?[]:Array.from({length:12},(_,i)=>({title:(g||'Both')+' '+i,author:'Author'}))]));
 const bookRows=Object.values(lists).flat().map(r=>({title:r.title,id:r.title,cover_url:'fixture-cover',series:null}));
 const ctx={URLSearchParams,DISPLAY_COUNT:10,FILTERED_POOL_SIZE:50,
  document:{getElementById(id){if(id==='get-recs-btn')return {addEventListener(_,fn){callbacks.fetch=fn;}};return elements[id];},querySelectorAll(){return buttons;}},
  sessionStorage:{getItem:k=>store.get(k)||null,setItem:(k,v)=>store.set(k,v),removeItem:k=>store.delete(k)},
  requireAuth:async()=>({user:{id:user}}),renderNav(){},loadRuleTargets(){},loadCurrentRules(){},
  sb:{from(table){return {select(){return {in(_,values){queries.push({table,values});return Promise.resolve({data:table==='books'?bookRows:bookRows.map(b=>({book_id:b.id,edition_type:'standard',narrators:['n']}))});}};}};}},
  renderResults:r=>{assert(Array.isArray(r));renders.push(clone(r));elements['results-area'].innerHTML=r.length?'rendered:'+r[0].title:'empty-success';},
  apiFetch:async url=>{calls.push(url);if(offline)throw Error('offline');if(status!==null)return {ok:false,status,json:async()=>({detail:'shared failure'})};
   const results=Object.fromEntries(Object.entries(lists).filter(([g])=>!fail.includes(g))),errors=Object.fromEntries(fail.map(g=>[g,'temporarily_unavailable']));
   return {ok:fail.length<3,status:fail.length===3?500:200,json:async()=>clone(version==='old'?results:{results_by_genre:results,errors_by_genre:errors})};}
 };
 vm.createContext(ctx);
 const start=source.indexOf("let session, currentGenre");const initStart=source.indexOf('(async () => {',start);const initEnd=source.indexOf('\n})();',initStart)+7;
 vm.runInContext(source.slice(start,initStart),ctx);
 for(const name of ['attachThumbnails','applyAudiobookFilter','applySeriesStatusFilter'])vm.runInContext(func(source,name),ctx);
 await vm.runInContext(source.slice(initStart,initEnd),ctx);
 const tabsStart=source.indexOf("document.querySelectorAll('#genre-toggle button').forEach",initEnd);
 vm.runInContext(source.slice(tabsStart,source.indexOf('\nasync function loadRuleTargets',tabsStart)),ctx);
 vm.runInContext(handler(source),ctx);
 // Preserve restored tab on reload; select an initial tab only with no cache.
 if(!store.size)vm.runInContext('currentGenre='+JSON.stringify(selected),ctx);
 return {store,calls,renders,queries,elements,async fetch(){await callbacks.fetch();assert.equal(elements.loading.style.display,'none');},tab(g){buttons.find(b=>b.dataset.genre===g).click();},state(){return JSON.parse(vm.runInContext('JSON.stringify({resultsByGenre,currentGenre'+(version==='old'?'':',errorsByGenre')+'})',ctx));},retry(){fail=[];offline=false;},clear(){vm.runInContext('clearRecsState()',ctx);}};
}
(async()=>{
 const output=[];
 // Actual full inline script must parse, independent of our selected execution slices.
 new vm.Script(now.slice(now.indexOf('<script>')+8,now.indexOf('</script>',now.indexOf('<script>'))));
 for(const filtered of [false,true]){
  const a=await setup(old,'old',{filtered}),b=await setup(now,'new',{filtered});await a.fetch();await b.fetch();
  assert.deepStrictEqual(a.renders,b.renders);assert.deepStrictEqual(a.state().resultsByGenre,b.state().resultsByGenre);
  assert.equal(b.calls[0],'/recommendations/all?top_n='+(filtered?50:10));output.push({case:'success',filtered,rendered:b.renders.at(-1).length});
 }
 for(const failed of ['', 'fantasy','sci_fi'])for(const selected of ['', 'fantasy','sci_fi']){
  const p=await setup(now,'new',{failed:[failed],selected,filtered:true});await p.fetch();
  const state=p.state();assert(!Object.hasOwn(state.resultsByGenre,failed));assert.equal(state.errorsByGenre[failed],'temporarily_unavailable');assert.equal(Object.keys(state.resultsByGenre).length,2);
  if(selected===failed)assert(p.elements['results-area'].innerHTML.includes("Couldn't load"));else assert(p.elements['results-area'].innerHTML.startsWith('rendered:'));
  p.tab(failed);assert(p.elements['results-area'].innerHTML.includes("Couldn't load"));
  // Save via actual tab handler, load via actual initializer in a NEW VM.
  const cached=JSON.parse(p.store.get('bookspell-cached-recs'));assert(!Object.hasOwn(cached.resultsByGenre,failed));assert.equal(cached.errorsByGenre[failed],'temporarily_unavailable');
  const reload=await setup(now,'new',{store:p.store});assert.equal(reload.state().errorsByGenre[failed],'temporarily_unavailable');assert(reload.elements['results-area'].innerHTML.includes("Couldn't load"));
  for(const healthy of ['', 'fantasy','sci_fi'].filter(g=>g!==failed)){reload.tab(healthy);assert(reload.elements['results-area'].innerHTML.startsWith('rendered:'));}
  // Success retry clears prior errors and replaces the cache.
  p.retry();await p.fetch();assert.deepStrictEqual(p.state().errorsByGenre,{});assert.equal(Object.keys(p.state().resultsByGenre).length,3);
  output.push({case:'partial',failed,selected,reloadPreservedError:true,healthyTabsWork:true,retryClearedError:true});
 }
 const all=await setup(now,'new',{failed:['','fantasy','sci_fi']});await all.fetch();assert(all.elements['results-area'].innerHTML.includes("Couldn't load recommendations"));assert.deepStrictEqual(all.state().resultsByGenre,{});
 const allReload=await setup(now,'new',{store:all.store});assert(allReload.elements['results-area'].innerHTML.includes("Couldn't load recommendations"));output.push({case:'all-failed',reloadError:true});
 const empty=await setup(now,'new',{empty:true});await empty.fetch();assert.equal(empty.elements['results-area'].innerHTML,'empty-success');assert.deepStrictEqual(empty.state().errorsByGenre,{});output.push({case:'empty-success'});
 for(const opts of [{network:true},{status:401},{status:500}]){
  const p=await setup(now,'new',opts);await p.fetch();assert(p.elements['results-area'].innerHTML.includes("Couldn't"));assert.equal(p.store.size,0);output.push({case:'request-failure',...opts});
 }
 // Legacy success cache remains readable, wrong-user cache isn't rendered.
 const legacy=new Map([['bookspell-cached-recs',JSON.stringify({userId:'fixture',currentGenre:'fantasy',resultsByGenre:{fantasy:[{title:'Legacy'}]}})]]);
 const p=await setup(now,'new',{store:legacy});assert.equal(p.renders[0][0].title,'Legacy');assert.deepStrictEqual(p.state().errorsByGenre,{});
 const other=await setup(now,'new',{store:legacy,user:'other'});assert.equal(other.renders.length,0);
 p.clear();assert.equal(p.store.size,0);assert.deepStrictEqual(p.state().resultsByGenre,{});assert.deepStrictEqual(p.state().errorsByGenre,{});
 output.push({case:'legacy-cache/user-isolation/invalidation'});
 fs.writeFileSync(path.join(E,'dashboard-results.json'),JSON.stringify(output,null,2)+'\n');
 console.log('PASS '+output.length+' dashboard scenarios; 9 partial-failure cache round-trips; actual fetch/tab/cache/reload/thumbnail/filter code; healthy lists never contain error metadata');
})().catch(e=>{console.error(e);process.exitCode=1;});
