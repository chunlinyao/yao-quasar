/* This software is in the public domain under CC0 1.0 Universal plus a Grant of Patent License. */
/*
You can get a key and certificate from QZ.io with a paid support agreement, or you can generate a single domain key for more restricted clients.

Generate Key and Cert:
$ openssl req -x509 -newkey rsa:2048 -keyout qz-private-key.pem -out digital-certificate.txt -days 11499 -nodes
- NOTE: make sure 'Common Name' is hostname like *.moqui.org ('localhost' works for local testing)

- add line to /opt/qz-tray/qz-tray.properties like: authcert.override=/opt/qz-tray/auth/digital-certificate.txt
- kill current process then restart or: java -Xms512m -jar /opt/qz-tray/qz-tray.jar

Add Files to Moqui:
- put qz-private-key.pem file on classpath (like runtime/classes or <component>/classes)
- add certificate hosted at path "/qz-tray/digital-certificate.txt" (in component use screen called qz-tray.xml and mount under webroot)
*/
if (window.qz && window.moqui && moqui.webrootVue) {
    console.info("Creating QZ component");
    moqui.loadComponent(moqui.webrootVue.appRootPath + '/cs/js/QzComponent.qvue', function(comp) {
        moqui.webrootVue.qzVue = comp;
    });

    moqui.isQzActive = function() { return qz.websocket.isActive(); };
    // NOTE useful options: jobName, copies, scaleContent, rasterize, rotation, etc; see https://qz.io/wiki/2.0-Pixel-Printing#advanced-printing
    moqui.getQzConfig = function(printer, userOptions, jobOptions) {
        var cfgOptions = { copies:1, jobName:null };
        if (moqui.isPlainObject(userOptions)) cfgOptions = $.extend(cfgOptions, userOptions);
        if (moqui.isPlainObject(jobOptions)) cfgOptions = $.extend(cfgOptions, jobOptions);
        // console.log("Combined options " + JSON.stringify(cfgOptions));

        var cfg = qz.configs.create(printer, cfgOptions);
        cfg.reconfigure(cfgOptions);
        console.log("QZ Config: " + JSON.stringify(cfg));
        return cfg;
    };
    moqui.getQzMainConfig = function(options) { return moqui.getQzConfig(moqui.webrootVue.$refs.qzVue.currentPrinter, moqui.webrootVue.$refs.qzVue.mainOptions, options); };
    moqui.getQzLabelConfig = function(options) { return moqui.getQzConfig(moqui.webrootVue.$refs.qzVue.currentLabelPrinter, moqui.webrootVue.$refs.qzVue.labelOptions, options); };
    moqui.showQzError = function(error) { console.log(error); moqui.notifyGrowl({type:"negative", title:error + ''}); };

    moqui.printUrlFile = function(config, url, type) {
        if (!url || !url.length) { console.warn("Called printUrlFile with no url array or string, printing nothing"); return; }
        if (!type || !type.length) type = "pdf";
        console.log("printing type " + type + " URL " + url);
        console.log(config);
        if (!moqui.isQzActive()) {
            moqui.notifyGrowl({type:"warning", title:"无法打印，QZ未连接。"});
            console.warn("Tried to print type " + type + " at URL " + url + " but QZ is not active");
            window.open(url);
            return;
        }

        var urlArray = moqui.isArray(url) ? url : [url];
        moqui.internalChainPrintFile(config, type, urlArray, 0);
    };
    moqui.internalChainPrintFile = function(config, type, urlArray, urlIndex) {
        if (!urlIndex) urlIndex = 0;
        if (urlIndex >= urlArray.length) return;
        var curUrl = urlArray[urlIndex];
        // pre-fetch the file, if we let QZ Tray do it the request won't be in the same session so there are authc/authz issues
        var oReq = new XMLHttpRequest();
        oReq.open("GET", curUrl, true);
        oReq.responseType = "blob";
        oReq.onload = function(oEvent) {
            var blob = oReq.response;
            var reader = new FileReader();
            reader.onloadend = function() {
                var base64data = reader.result;
                var base64Only = base64data.substr(base64data.indexOf(',')+1);
                var printDataObj = { type:type, format:"base64", data:base64Only };
                qz.print(config, [printDataObj]).catch(moqui.showQzError).then(function () {
                    var nextIndex = urlIndex + 1;
                    if (nextIndex < urlArray.length) { moqui.internalChainPrintFile(config, type, urlArray, nextIndex); }
                });
            };
            reader.readAsDataURL(blob);
        };
        oReq.send();
    };
    moqui.printUrlMain = function(url, type, jobOptions) { moqui.printUrlFile(moqui.getQzMainConfig(jobOptions), url, type); };
    moqui.printUrlLabel = function(url, type, jobOptions) { moqui.printUrlFile(moqui.getQzLabelConfig(jobOptions), url, type); };

} else {
    console.info("Not creating QZ component, qz: " + window.qz + ", moqui: " + window.moqui)
}
