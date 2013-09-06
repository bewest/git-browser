#!/usr/bin/env node
var T = require('./utils/task.js');

// Override paths using environment variables
var WEBDIR = process.env.WEBDIR || "build/web";
var MOZDIR = process.env.MOZDIR || "build/moz";
var CHROMEDIR = process.env.CHROMEDIR || "build/chrome";

T("all", ["web", "moz", "chrome"]);

function base(bootstrap, targetDir) {
  return T.parallel(
    T.copy("res", targetDir),
    T.lessc("src/style.less", targetDir + "/style.css"),
    T.build("src/" + bootstrap, targetDir + "/app.js")
  );
}

T("web", base("web.js", WEBDIR));

T("moz", T.parallel(
  base("firefox.js", MOZDIR),
  T.copy("src/manifest.webapp", MOZDIR + "/manifest.webapp")
));

T("chrome", T.parallel(
  base("chrome.js", CHROMEDIR),
  T.copy("src/manifest.json", CHROMEDIR + "/manifest.json"),
  T.copy("src/background.js", CHROMEDIR + "/background.js")
));

T("clean", T.rmrf("build"));

T.execute(T.run, process.argv.slice(2), function (err) {
  if (err) {
    console.error(err.stack || err);
    process.exit(-1);
  }
  console.log("Done");
});