const fs = require('node:fs');
const path = require('node:path');

const files = fs.readdirSync('app').filter(name => name.endsWith('.html')).sort();
if (files.length === 0) {
  console.error('No app/*.html files found.');
  process.exit(1);
}

for (const name of files) {
  const file = path.join('app', name);
  const html = fs.readFileSync(file, 'utf8');
  // Match inline blocks only; never consume a preceding external script.
  const blocks = [...html.matchAll(/<script\s*>((?:(?!<\/script\s*>)[\s\S])*)<\/script\s*>/gi)];
  const last = blocks.at(-1);
  if (!last || !/^\s*<\/body\s*>/i.test(html.slice(last.index + last[0].length))) {
    console.error(`${file}: missing inline script immediately before </body>.`);
    process.exitCode = 1;
    continue;
  }
  for (const [index, block] of blocks.entries()) {
    try {
      new Function(block[1]);
      console.log(`${file}: inline script ${index + 1} OK`);
    } catch (error) {
      console.error(`${file}: inline script ${index + 1}: ${error.message}`);
      process.exitCode = 1;
    }
  }
}
