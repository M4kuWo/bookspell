// Execute the actual old/current click-handler source with deterministic HTTP/DOM boundaries.
const fs=require('fs'),vm=require('vm'),cp=require('child_process'),path=require('path');
const E=__dirname,root=path.resolve(E,'../../..');
const old=cp.execFileSync('git',['show','e8281c2^:app/dashboard.html'],{cwd:root,encoding:'utf8'});
const now=fs.readFileSync(path.join(root,'app/dashboard.html'),'utf8');
function handler(text){const start=text.indexOf("document.getElementById('get-recs-btn').addEventListener"); const end=text.indexOf('\n});',start)+5; if(start<0||end<5)throw Error('handler missing');return text.slice(start,end);}
async function run(source,version,failed,currentGenre='fantasy',network=false,filtered=false){
 const lists={'':[{title:'All'}],fantasy:[{title:'Fantasy'}],sci_fi:[{title:'SF'}]};
 const elements={'loading':{style:{}},'results-area':{innerHTML:''},'audiobook-filter':{value:filtered?'any':''},'series-status-filter':{value:''}};
 let callback;const calls=[],renders=[];
 const ctx={resultsByGenre:{},currentGenre,DISPLAY_COUNT:10,FILTERED_POOL_SIZE:50,URLSearchParams,
  document:{getElementById(id){if(id==='get-recs-btn')return {addEventListener(_,fn){callback=fn;}};return elements[id];}},
  apiFetch:async url=>{calls.push(url);if(network)throw Error('network failure');
   if(version==='old'){const genre=new URL(url,'http://fixture').searchParams.get('genre')||'';return {ok:genre!==failed,json:async()=>({results:lists[genre]})};}
   return {ok:failed===null,json:async()=>lists};},
  attachThumbnails:async()=>{},applyAudiobookFilter:async()=>{},applySeriesStatusFilter:()=>{},renderResults:r=>renders.push(r),saveRecsCache:()=>{}};
 vm.createContext(ctx);vm.runInContext(handler(source),ctx);await callback();
 return {calls,results:ctx.resultsByGenre,renders,message:elements['results-area'].innerHTML,loading:elements.loading.style.display};
}
(async()=>{const results={};for(const [label,failed,genre,network,filtered] of [['success',null,'fantasy',false,false],['filtered',null,'sci_fi',false,true],['other_genre_500','sci_fi','fantasy',false,false],['current_genre_500','sci_fi','sci_fi',false,false],['network_rejection',null,'fantasy',true,false]]){
 const before=await run(old,'old',failed,genre,network,filtered),after=await run(now,'new',failed,genre,network,filtered);
 if(before.loading!=='none'||after.loading!=='none')throw Error('spinner not cleared');
 if(failed===null&&!network&&JSON.stringify(before.renders)!==JSON.stringify(after.renders))throw Error('success output differs');
 results[label]={before,after};
 }
 if(results.other_genre_500.before.renders.length!==1||results.other_genre_500.after.renders.length!==0)throw Error('partial regression not reproduced');
 fs.writeFileSync(path.join(E,'dashboard-results.json'),JSON.stringify(results,null,2)+'\n');
 console.log('PASS 5 actual-handler scenarios before/after: success, filtered, other/current genre HTTP 500, network rejection; isolated HTTP failure loses healthy results after consolidation');
})().catch(e=>{console.error(e);process.exitCode=1;});
