/*!
* Fine Uploader
*
* Copyright 2013, Widen Enterprises, Inc. info@fineuploader.com
*
* Version: 4.2.2
*
* Homepage: http://fineuploader.com
*
* Repository: git://github.com/Widen/fine-uploader.git
*
* Licensed under GNU GPL v3, see LICENSE
*/ 


/*globals window, navigator, document, FormData, File, HTMLInputElement, XMLHttpRequest, Blob, Storage, ActiveXObject */
var qq = function(element) {
    "use strict";

    return {
        hide: function() {
            element.style.display = "none";
            return this;
        },

        /** Returns the function which detaches attached event */
        attach: function(type, fn) {
            if (element.addEventListener){
                element.addEventListener(type, fn, false);
            } else if (element.attachEvent){
                element.attachEvent("on" + type, fn);
            }
            return function() {
                qq(element).detach(type, fn);
            };
        },

        detach: function(type, fn) {
            if (element.removeEventListener){
                element.removeEventListener(type, fn, false);
            } else if (element.attachEvent){
                element.detachEvent("on" + type, fn);
            }
            return this;
        },

        contains: function(descendant) {
            // The [W3C spec](http://www.w3.org/TR/domcore/#dom-node-contains)
            // says a `null` (or ostensibly `undefined`) parameter
            // passed into `Node.contains` should result in a false return value.
            // IE7 throws an exception if the parameter is `undefined` though.
            if (!descendant) {
                return false;
            }

            // compareposition returns false in this case
            if (element === descendant) {
                return true;
            }

            if (element.contains){
                return element.contains(descendant);
            } else {
                /*jslint bitwise: true*/
                return !!(descendant.compareDocumentPosition(element) & 8);
            }
        },

        /**
         * Insert this element before elementB.
         */
        insertBefore: function(elementB) {
            elementB.parentNode.insertBefore(element, elementB);
            return this;
        },

        remove: function() {
            element.parentNode.removeChild(element);
            return this;
        },

        /**
         * Sets styles for an element.
         * Fixes opacity in IE6-8.
         */
        css: function(styles) {
            /*jshint eqnull: true*/
            if (element.style == null) {
                throw new qq.Error("Can't apply style to node as it is not on the HTMLElement prototype chain!");
            }

            /*jshint -W116*/
            if (styles.opacity != null){
                if (typeof element.style.opacity !== "string" && typeof(element.filters) !== "undefined"){
                    styles.filter = "alpha(opacity=" + Math.round(100 * styles.opacity) + ")";
                }
            }
            qq.extend(element.style, styles);

            return this;
        },

        hasClass: function(name) {
            var re = new RegExp("(^| )" + name + "( |$)");
            return re.test(element.className);
        },

        addClass: function(name) {
            if (!qq(element).hasClass(name)){
                element.className += " " + name;
            }
            return this;
        },

        removeClass: function(name) {
            var re = new RegExp("(^| )" + name + "( |$)");
            element.className = element.className.replace(re, " ").replace(/^\s+|\s+$/g, "");
            return this;
        },

        getByClass: function(className) {
            var candidates,
                result = [];

            if (element.querySelectorAll){
                return element.querySelectorAll("." + className);
            }

            candidates = element.getElementsByTagName("*");

            qq.each(candidates, function(idx, val) {
                if (qq(val).hasClass(className)){
                    result.push(val);
                }
            });
            return result;
        },

        children: function() {
            var children = [],
                child = element.firstChild;

            while (child){
                if (child.nodeType === 1){
                    children.push(child);
                }
                child = child.nextSibling;
            }

            return children;
        },

        setText: function(text) {
            element.innerText = text;
            element.textContent = text;
            return this;
        },

        clearText: function() {
            return qq(element).setText("");
        },

        // Returns true if the attribute exists on the element
        // AND the value of the attribute is NOT "false" (case-insensitive)
        hasAttribute: function(attrName) {
            var attrVal;

            if (element.hasAttribute) {

                if (!element.hasAttribute(attrName)) {
                    return false;
                }

                /*jshint -W116*/
                return (/^false$/i).exec(element.getAttribute(attrName)) == null;
            }
            else {
                attrVal = element[attrName];

                if (attrVal === undefined) {
                    return false;
                }

                /*jshint -W116*/
                return (/^false$/i).exec(attrVal) == null;
            }
        }
    };
};

(function(){
    "use strict";

    qq.log = function(message, level) {
        if (window.console) {
            if (!level || level === "info") {
                window.console.log(message);
            }
            else
            {
                if (window.console[level]) {
                    window.console[level](message);
                }
                else {
                    window.console.log("<" + level + "> " + message);
                }
            }
        }
    };

    qq.isObject = function(variable) {
        return variable && !variable.nodeType && Object.prototype.toString.call(variable) === "[object Object]";
    };

    qq.isFunction = function(variable) {
        return typeof(variable) === "function";
    };

    /**
     * Check the type of a value.  Is it an "array"?
     *
     * @param value value to test.
     * @returns true if the value is an array or associated with an `ArrayBuffer`
     */
    qq.isArray = function(value) {
        return Object.prototype.toString.call(value) === "[object Array]" ||
            (value && window.ArrayBuffer && value.buffer && value.buffer.constructor === ArrayBuffer);
    };

    // Looks for an object on a `DataTransfer` object that is associated with drop events when utilizing the Filesystem API.
    qq.isItemList = function(maybeItemList) {
        return Object.prototype.toString.call(maybeItemList) === "[object DataTransferItemList]";
    };

    // Looks for an object on a `NodeList` or an `HTMLCollection`|`HTMLFormElement`|`HTMLSelectElement`
    // object that is associated with collections of Nodes.
    qq.isNodeList = function(maybeNodeList) {
        return Object.prototype.toString.call(maybeNodeList) === "[object NodeList]" ||
            // If `HTMLCollection` is the actual type of the object, we must determine this
            // by checking for expected properties/methods on the object
            (maybeNodeList.item && maybeNodeList.namedItem);
    };

    qq.isString = function(maybeString) {
        return Object.prototype.toString.call(maybeString) === "[object String]";
    };

    qq.trimStr = function(string) {
        if (String.prototype.trim) {
            return string.trim();
        }

        return string.replace(/^\s+|\s+$/g,"");
    };


    /**
     * @param str String to format.
     * @returns {string} A string, swapping argument values with the associated occurrence of {} in the passed string.
     */
    qq.format = function(str) {

        var args =  Array.prototype.slice.call(arguments, 1),
            newStr = str,
            nextIdxToReplace = newStr.indexOf("{}");

        qq.each(args, function(idx, val) {
            var strBefore = newStr.substring(0, nextIdxToReplace),
                strAfter = newStr.substring(nextIdxToReplace+2);

            newStr = strBefore + val + strAfter;
            nextIdxToReplace = newStr.indexOf("{}", nextIdxToReplace + val.length);

            // End the loop if we have run out of tokens (when the arguments exceed the # of tokens)
            if (nextIdxToReplace < 0) {
                return false;
            }
        });

        return newStr;
    };

    qq.isFile = function(maybeFile) {
        return window.File && Object.prototype.toString.call(maybeFile) === "[object File]";
    };

    qq.isFileList = function(maybeFileList) {
        return window.FileList && Object.prototype.toString.call(maybeFileList) === "[object FileList]";
    };

    qq.isFileOrInput = function(maybeFileOrInput) {
        return qq.isFile(maybeFileOrInput) || qq.isInput(maybeFileOrInput);
    };

    qq.isInput = function(maybeInput) {
        if (window.HTMLInputElement) {
            if (Object.prototype.toString.call(maybeInput) === "[object HTMLInputElement]") {
                if (maybeInput.type && maybeInput.type.toLowerCase() === "file") {
                    return true;
                }
            }
        }
        if (maybeInput.tagName) {
            if (maybeInput.tagName.toLowerCase() === "input") {
                if (maybeInput.type && maybeInput.type.toLowerCase() === "file") {
                    return true;
                }
            }
        }

        return false;
    };

    qq.isBlob = function(maybeBlob) {
        return window.Blob && Object.prototype.toString.call(maybeBlob) === "[object Blob]";
    };

    qq.isXhrUploadSupported = function() {
        var input = document.createElement("input");
        input.type = "file";

        return (
            input.multiple !== undefined &&
                typeof File !== "undefined" &&
                typeof FormData !== "undefined" &&
                typeof (qq.createXhrInstance()).upload !== "undefined" );
    };

    // Fall back to ActiveX is native XHR is disabled (possible in any version of IE).
    qq.createXhrInstance = function() {
        if (window.XMLHttpRequest) {
            return new XMLHttpRequest();
        }

        try {
            return new ActiveXObject("MSXML2.XMLHTTP.3.0");
        }
        catch(error) {
            qq.log("Neither XHR or ActiveX are supported!", "error");
            return null;
        }
    };

    qq.isFolderDropSupported = function(dataTransfer) {
        return (dataTransfer.items && dataTransfer.items[0].webkitGetAsEntry);
    };

    qq.isFileChunkingSupported = function() {
        return !qq.android() && //android's impl of Blob.slice is broken
            qq.isXhrUploadSupported() &&
            (File.prototype.slice !== undefined || File.prototype.webkitSlice !== undefined || File.prototype.mozSlice !== undefined);
    };

    qq.sliceBlob = function(fileOrBlob, start, end) {
        var slicer = fileOrBlob.slice || fileOrBlob.mozSlice || fileOrBlob.webkitSlice;

        return slicer.call(fileOrBlob, start, end);
    };

    qq.arrayBufferToHex = function(buffer) {
        var bytesAsHex = "",
            bytes = new Uint8Array(buffer);


        qq.each(bytes, function(idx, byte) {
            var byteAsHexStr = byte.toString(16);

            if (byteAsHexStr.length < 2) {
                byteAsHexStr = "0" + byteAsHexStr;
            }

            bytesAsHex += byteAsHexStr;
        });

        return bytesAsHex;
    };

    qq.readBlobToHex = function(blob, startOffset, length) {
        var initialBlob = qq.sliceBlob(blob, startOffset, startOffset + length),
            fileReader = new FileReader(),
            promise = new qq.Promise();

        fileReader.onload = function() {
            promise.success(qq.arrayBufferToHex(fileReader.result));
        };

        fileReader.readAsArrayBuffer(initialBlob);

        return promise;
    };

    qq.extend = function(first, second, extendNested) {
        qq.each(second, function(prop, val) {
            if (extendNested && qq.isObject(val)) {
                if (first[prop] === undefined) {
                    first[prop] = {};
                }
                qq.extend(first[prop], val, true);
            }
            else {
                first[prop] = val;
            }
        });

        return first;
    };

    /**
     * Allow properties in one object to override properties in another,
     * keeping track of the original values from the target object.
     *
     * Note that the pre-overriden properties to be overriden by the source will be passed into the `sourceFn` when it is invoked.
     *
     * @param target Update properties in this object from some source
     * @param sourceFn A function that, when invoked, will return properties that will replace properties with the same name in the target.
     * @returns {object} The target object
     */
    qq.override = function(target, sourceFn) {
        var super_ = {},
            source = sourceFn(super_);

        qq.each(source, function(srcPropName, srcPropVal) {
            if (target[srcPropName] !== undefined) {
                super_[srcPropName] = target[srcPropName];
            }

            target[srcPropName] = srcPropVal;
        });

        return target;
    };

    /**
     * Searches for a given element in the array, returns -1 if it is not present.
     * @param {Number} [from] The index at which to begin the search
     */
    qq.indexOf = function(arr, elt, from){
        if (arr.indexOf) {
            return arr.indexOf(elt, from);
        }

        from = from || 0;
        var len = arr.length;

        if (from < 0) {
            from += len;
        }

        for (; from < len; from+=1){
            if (arr.hasOwnProperty(from) && arr[from] === elt){
                return from;
            }
        }
        return -1;
    };

    //this is a version 4 UUID
    qq.getUniqueId = function(){
        return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function(c) {
            /*jslint eqeq: true, bitwise: true*/
            var r = Math.random()*16|0, v = c == "x" ? r : (r&0x3|0x8);
            return v.toString(16);
        });
    };

    //
    // Browsers and platforms detection

    qq.ie       = function(){
        return navigator.userAgent.indexOf("MSIE") !== -1;
    };
    qq.ie7      = function(){
        return navigator.userAgent.indexOf("MSIE 7") !== -1;
    };
    qq.ie10     = function(){
        return navigator.userAgent.indexOf("MSIE 10") !== -1;
    };
    qq.ie11     = function(){
        return (navigator.userAgent.indexOf("Trident") !== -1 &&
            navigator.userAgent.indexOf("rv:11") !== -1);
    };
    qq.safari   = function(){
        return navigator.vendor !== undefined && navigator.vendor.indexOf("Apple") !== -1;
    };
    qq.chrome   = function(){
        return navigator.vendor !== undefined && navigator.vendor.indexOf("Google") !== -1;
    };
    qq.opera   = function(){
        return navigator.vendor !== undefined && navigator.vendor.indexOf("Opera") !== -1;
    };
    qq.firefox  = function(){
        return (!qq.ie11() && navigator.userAgent.indexOf("Mozilla") !== -1 && navigator.vendor !== undefined && navigator.vendor === "");
    };
    qq.windows  = function(){
        return navigator.platform === "Win32";
    };
    qq.android = function(){
        return navigator.userAgent.toLowerCase().indexOf("android") !== -1;
    };
    qq.ios7 = function() {
        return qq.ios() && navigator.userAgent.indexOf(" OS 7_") !== -1;
    };
    qq.ios = function() {
        /*jshint -W014 */
        return navigator.userAgent.indexOf("iPad") !== -1
            || navigator.userAgent.indexOf("iPod") !== -1
            || navigator.userAgent.indexOf("iPhone") !== -1;
    };

    //
    // Events

    qq.preventDefault = function(e){
        if (e.preventDefault){
            e.preventDefault();
        } else{
            e.returnValue = false;
        }
    };

    /**
     * Creates and returns element from html string
     * Uses innerHTML to create an element
     */
    qq.toElement = (function(){
        var div = document.createElement("div");
        return function(html){
            div.innerHTML = html;
            var element = div.firstChild;
            div.removeChild(element);
            return element;
        };
    }());

    //key and value are passed to callback for each entry in the iterable item
    qq.each = function(iterableItem, callback) {
        var keyOrIndex, retVal;

        if (iterableItem) {
            // Iterate through [`Storage`](http://www.w3.org/TR/webstorage/#the-storage-interface) items
            if (window.Storage && iterableItem.constructor === window.Storage) {
                for (keyOrIndex = 0; keyOrIndex < iterableItem.length; keyOrIndex++) {
                    retVal = callback(iterableItem.key(keyOrIndex), iterableItem.getItem(iterableItem.key(keyOrIndex)));
                    if (retVal === false) {
                        break;
                    }
                }
            }
            // `DataTransferItemList` & `NodeList` objects are array-like and should be treated as arrays
            // when iterating over items inside the object.
            else if (qq.isArray(iterableItem) || qq.isItemList(iterableItem) || qq.isNodeList(iterableItem)) {
                for (keyOrIndex = 0; keyOrIndex < iterableItem.length; keyOrIndex++) {
                    retVal = callback(keyOrIndex, iterableItem[keyOrIndex]);
                    if (retVal === false) {
                        break;
                    }
                }
            }
            else if (qq.isString(iterableItem)) {
                for (keyOrIndex = 0; keyOrIndex < iterableItem.length; keyOrIndex++) {
                    retVal = callback(keyOrIndex, iterableItem.charAt(keyOrIndex));
                    if (retVal === false) {
                        break;
                    }
                }
            }
            else {
                for (keyOrIndex in iterableItem) {
                    if (Object.prototype.hasOwnProperty.call(iterableItem, keyOrIndex)) {
                        retVal = callback(keyOrIndex, iterableItem[keyOrIndex]);
                        if (retVal === false) {
                            break;
                        }
                    }
                }
            }
        }
    };

    //include any args that should be passed to the new function after the context arg
    qq.bind = function(oldFunc, context) {
        if (qq.isFunction(oldFunc)) {
            var args =  Array.prototype.slice.call(arguments, 2);

            return function() {
                var newArgs = qq.extend([], args);
                if (arguments.length) {
                    newArgs = newArgs.concat(Array.prototype.slice.call(arguments));
                }
                return oldFunc.apply(context, newArgs);
            };
        }

        throw new Error("first parameter must be a function!");
    };

    /**
     * obj2url() takes a json-object as argument and generates
     * a querystring. pretty much like jQuery.param()
     *
     * how to use:
     *
     *    `qq.obj2url({a:'b',c:'d'},'http://any.url/upload?otherParam=value');`
     *
     * will result in:
     *
     *    `http://any.url/upload?otherParam=value&a=b&c=d`
     *
     * @param  Object JSON-Object
     * @param  String current querystring-part
     * @return String encoded querystring
     */
    qq.obj2url = function(obj, temp, prefixDone){
        /*jshint laxbreak: true*/
        var uristrings = [],
            prefix = "&",
            add = function(nextObj, i){
                var nextTemp = temp
                    ? (/\[\]$/.test(temp)) // prevent double-encoding
                    ? temp
                    : temp+"["+i+"]"
                    : i;
                if ((nextTemp !== "undefined") && (i !== "undefined")) {
                    uristrings.push(
                        (typeof nextObj === "object")
                            ? qq.obj2url(nextObj, nextTemp, true)
                            : (Object.prototype.toString.call(nextObj) === "[object Function]")
                            ? encodeURIComponent(nextTemp) + "=" + encodeURIComponent(nextObj())
                            : encodeURIComponent(nextTemp) + "=" + encodeURIComponent(nextObj)
                    );
                }
            };

        if (!prefixDone && temp) {
            prefix = (/\?/.test(temp)) ? (/\?$/.test(temp)) ? "" : "&" : "?";
            uristrings.push(temp);
            uristrings.push(qq.obj2url(obj));
        } else if ((Object.prototype.toString.call(obj) === "[object Array]") && (typeof obj !== "undefined") ) {
            qq.each(obj, function(idx, val) {
                add(val, idx);
            });
        } else if ((typeof obj !== "undefined") && (obj !== null) && (typeof obj === "object")){
            qq.each(obj, function(prop, val) {
                add(val, prop);
            });
        } else {
            uristrings.push(encodeURIComponent(temp) + "=" + encodeURIComponent(obj));
        }

        if (temp) {
            return uristrings.join(prefix);
        } else {
            return uristrings.join(prefix)
                .replace(/^&/, "")
                .replace(/%20/g, "+");
        }
    };

    qq.obj2FormData = function(obj, formData, arrayKeyName) {
        if (!formData) {
            formData = new FormData();
        }

        qq.each(obj, function(key, val) {
            key = arrayKeyName ? arrayKeyName + "[" + key + "]" : key;

            if (qq.isObject(val)) {
                qq.obj2FormData(val, formData, key);
            }
            else if (qq.isFunction(val)) {
                formData.append(key, val());
            }
            else {
                formData.append(key, val);
            }
        });

        return formData;
    };

    qq.obj2Inputs = function(obj, form) {
        var input;

        if (!form) {
            form = document.createElement("form");
        }

        qq.obj2FormData(obj, {
            append: function(key, val) {
                input = document.createElement("input");
                input.setAttribute("name", key);
                input.setAttribute("value", val);
                form.appendChild(input);
            }
        });

        return form;
    };

    qq.setCookie = function(name, value, days) {
        var date = new Date(),
            expires = "";

        if (days) {
            date.setTime(date.getTime()+(days*24*60*60*1000));
            expires = "; expires="+date.toGMTString();
        }

        document.cookie = name+"="+value+expires+"; path=/";
    };

    qq.getCookie = function(name) {
        var nameEQ = name + "=",
            ca = document.cookie.split(";"),
            cookie;

        qq.each(ca, function(idx, part) {
            /*jshint -W116 */
            var cookiePart = part;
            while (cookiePart.charAt(0) == " ") {
                cookiePart = cookiePart.substring(1, cookiePart.length);
            }

            if (cookiePart.indexOf(nameEQ) === 0) {
                cookie = cookiePart.substring(nameEQ.length, cookiePart.length);
                return false;
            }
        });

        return cookie;
    };

    qq.getCookieNames = function(regexp) {
        var cookies = document.cookie.split(";"),
            cookieNames = [];

        qq.each(cookies, function(idx, cookie) {
            cookie = qq.trimStr(cookie);

            var equalsIdx = cookie.indexOf("=");

            if (cookie.match(regexp)) {
                cookieNames.push(cookie.substr(0, equalsIdx));
            }
        });

        return cookieNames;
    };

    qq.deleteCookie = function(name) {
        qq.setCookie(name, "", -1);
    };

    qq.areCookiesEnabled = function() {
        var randNum = Math.random() * 100000,
            name = "qqCookieTest:" + randNum;
        qq.setCookie(name, 1);

        if (qq.getCookie(name)) {
            qq.deleteCookie(name);
            return true;
        }
        return false;
    };

    /**
     * Not recommended for use outside of Fine Uploader since this falls back to an unchecked eval if JSON.parse is not
     * implemented.  For a more secure JSON.parse polyfill, use Douglas Crockford's json2.js.
     */
    qq.parseJson = function(json) {
        /*jshint evil: true*/
        if (window.JSON && qq.isFunction(JSON.parse)) {
            return JSON.parse(json);
        } else {
            return eval("(" + json + ")");
        }
    };

    /**
     * Retrieve the extension of a file, if it exists.
     *
     * @param filename
     * @returns {string || undefined}
     */
    qq.getExtension = function(filename) {
        var extIdx = filename.lastIndexOf(".") + 1;

        if (extIdx > 0) {
            return filename.substr(extIdx, filename.length - extIdx);
        }
    };

    qq.getFilename = function(blobOrFileInput) {
        /*jslint regexp: true*/

        if (qq.isInput(blobOrFileInput)) {
            // get input value and remove path to normalize
            return blobOrFileInput.value.replace(/.*(\/|\\)/, "");
        }
        else if (qq.isFile(blobOrFileInput)) {
            if (blobOrFileInput.fileName !== null && blobOrFileInput.fileName !== undefined) {
                return blobOrFileInput.fileName;
            }
        }

        return blobOrFileInput.name;
    };

    /**
     * A generic module which supports object disposing in dispose() method.
     * */
    qq.DisposeSupport = function() {
        var disposers = [];

        return {
            /** Run all registered disposers */
            dispose: function() {
                var disposer;
                do {
                    disposer = disposers.shift();
                    if (disposer) {
                        disposer();
                    }
                }
                while (disposer);
            },

            /** Attach event handler and register de-attacher as a disposer */
            attach: function() {
                var args = arguments;
                /*jslint undef:true*/
                this.addDisposer(qq(args[0]).attach.apply(this, Array.prototype.slice.call(arguments, 1)));
            },

            /** Add disposer to the collection */
            addDisposer: function(disposeFunction) {
                disposers.push(disposeFunction);
            }
        };
    };
}());

/* globals qq */
/**
 * Fine Uploader top-level Error container.  Inherits from `Error`.
 */
(function() {
    "use strict";

    qq.Error = function(message) {
        this.message = message;
    };

    qq.Error.prototype = new Error();
}());

/*global qq */
qq.version="4.2.2";

/* globals qq */
qq.supportedFeatures = (function () {
    "use strict";

    var supportsUploading,
        supportsAjaxFileUploading,
        supportsFolderDrop,
        supportsChunking,
        supportsResume,
        supportsUploadViaPaste,
        supportsUploadCors,
        supportsDeleteFileXdr,
        supportsDeleteFileCorsXhr,
        supportsDeleteFileCors,
        supportsFolderSelection,
        supportsImagePreviews;


    function testSupportsFileInputElement() {
        var supported = true,
            tempInput;

        try {
            tempInput = document.createElement("input");
            tempInput.type = "file";
            qq(tempInput).hide();

            if (tempInput.disabled) {
                supported = false;
            }
        }
        catch (ex) {
            supported = false;
        }

        return supported;
    }

    //only way to test for Filesystem API support since webkit does not expose the DataTransfer interface
    function isChrome21OrHigher() {
        return (qq.chrome() || qq.opera()) &&
            navigator.userAgent.match(/Chrome\/[2][1-9]|Chrome\/[3-9][0-9]/) !== undefined;
    }

    //only way to test for complete Clipboard API support at this time
    function isChrome14OrHigher() {
        return (qq.chrome() || qq.opera()) &&
            navigator.userAgent.match(/Chrome\/[1][4-9]|Chrome\/[2-9][0-9]/) !== undefined;
    }

    //Ensure we can send cross-origin `XMLHttpRequest`s
    function isCrossOriginXhrSupported() {
        if (window.XMLHttpRequest) {
            var xhr = qq.createXhrInstance();

            //Commonly accepted test for XHR CORS support.
            return xhr.withCredentials !== undefined;
        }

        return false;
    }

    //Test for (terrible) cross-origin ajax transport fallback for IE9 and IE8
    function isXdrSupported() {
        return window.XDomainRequest !== undefined;
    }

    // CORS Ajax requests are supported if it is either possible to send credentialed `XMLHttpRequest`s,
    // or if `XDomainRequest` is an available alternative.
    function isCrossOriginAjaxSupported() {
        if (isCrossOriginXhrSupported()) {
            return true;
        }

        return isXdrSupported();
    }

    function isFolderSelectionSupported() {
        // We know that folder selection is only supported in Chrome via this proprietary attribute for now
        return document.createElement("input").webkitdirectory !== undefined;
    }


    supportsUploading = testSupportsFileInputElement();

    supportsAjaxFileUploading = supportsUploading && qq.isXhrUploadSupported();

    supportsFolderDrop = supportsAjaxFileUploading && isChrome21OrHigher();

    supportsChunking = supportsAjaxFileUploading && qq.isFileChunkingSupported();

    supportsResume = supportsAjaxFileUploading && supportsChunking && qq.areCookiesEnabled();

    supportsUploadViaPaste = supportsAjaxFileUploading && isChrome14OrHigher();

    supportsUploadCors = supportsUploading && (window.postMessage !== undefined || supportsAjaxFileUploading);

    supportsDeleteFileCorsXhr = isCrossOriginXhrSupported();

    supportsDeleteFileXdr = isXdrSupported();

    supportsDeleteFileCors = isCrossOriginAjaxSupported();

    supportsFolderSelection = isFolderSelectionSupported();

    supportsImagePreviews = supportsAjaxFileUploading && window.FileReader !== undefined;


    return {
        uploading: supportsUploading,
        ajaxUploading: supportsAjaxFileUploading,
        fileDrop: supportsAjaxFileUploading, //NOTE: will also return true for touch-only devices.  It's not currently possible to accurately test for touch-only devices
        folderDrop: supportsFolderDrop,
        chunking: supportsChunking,
        resume: supportsResume,
        uploadCustomHeaders: supportsAjaxFileUploading,
        uploadNonMultipart: supportsAjaxFileUploading,
        itemSizeValidation: supportsAjaxFileUploading,
        uploadViaPaste: supportsUploadViaPaste,
        progressBar: supportsAjaxFileUploading,
        uploadCors: supportsUploadCors,
        deleteFileCorsXhr: supportsDeleteFileCorsXhr,
        deleteFileCorsXdr: supportsDeleteFileXdr, //NOTE: will also return true in IE10, where XDR is also supported
        deleteFileCors: supportsDeleteFileCors,
        canDetermineSize: supportsAjaxFileUploading,
        folderSelection: supportsFolderSelection,
        imagePreviews: supportsImagePreviews,
        imageValidation: supportsImagePreviews,
        pause: supportsChunking
    };

}());

/*globals qq*/
qq.Promise = function() {
    "use strict";

    var successArgs, failureArgs,
        successCallbacks = [],
        failureCallbacks = [],
        doneCallbacks = [],
        state = 0;

    qq.extend(this, {
        then: function(onSuccess, onFailure) {
            if (state === 0) {
                if (onSuccess) {
                    successCallbacks.push(onSuccess);
                }
                if (onFailure) {
                    failureCallbacks.push(onFailure);
                }
            }
            else if (state === -1) {
                onFailure && onFailure.apply(null, failureArgs);
            }
            else if (onSuccess) {
                onSuccess.apply(null,successArgs);
            }

            return this;
        },

        done: function(callback) {
            if (state === 0) {
                doneCallbacks.push(callback);
            }
            else {
                callback.apply(null, failureArgs === undefined ? successArgs : failureArgs);
            }

            return this;
        },

        success: function() {
            state = 1;
            successArgs = arguments;

            if (successCallbacks.length) {
                qq.each(successCallbacks, function(idx, callback) {
                    callback.apply(null, successArgs);
                });
            }

            if(doneCallbacks.length) {
                qq.each(doneCallbacks, function(idx, callback) {
                    callback.apply(null, successArgs);
                });
            }

            return this;
        },

        failure: function() {
            state = -1;
            failureArgs = arguments;

            if (failureCallbacks.length) {
                qq.each(failureCallbacks, function(idx, callback) {
                    callback.apply(null, failureArgs);
                });
            }

            if(doneCallbacks.length) {
                qq.each(doneCallbacks, function(idx, callback) {
                    callback.apply(null, failureArgs);
                });
            }

            return this;
        }
    });
};

/*globals qq*/

/**
 * This module represents an upload or "Select File(s)" button.  It's job is to embed an opaque `<input type="file">`
 * element as a child of a provided "container" element.  This "container" element (`options.element`) is used to provide
 * a custom style for the `<input type="file">` element.  The ability to change the style of the container element is also
 * provided here by adding CSS classes to the container on hover/focus.
 *
 * TODO Eliminate the mouseover and mouseout event handlers since the :hover CSS pseudo-class should now be
 * available on all supported browsers.
 *
 * @param o Options to override the default values
 */
qq.UploadButton = function(o) {
    "use strict";


    var disposeSupport = new qq.DisposeSupport(),

        options = {
            // "Container" element
            element: null,

            // If true adds `multiple` attribute to `<input type="file">`
            multiple: false,

            // Corresponds to the `accept` attribute on the associated `<input type="file">`
            acceptFiles: null,

            // A true value allows folders to be selected, if supported by the UA
            folders: false,

            // `name` attribute of `<input type="file">`
            name: "qqfile",

            // Called when the browser invokes the onchange handler on the `<input type="file">`
            onChange: function(input) {},

            // **This option will be removed** in the future as the :hover CSS pseudo-class is available on all supported browsers
            hoverClass: "qq-upload-button-hover",

            focusClass: "qq-upload-button-focus"
        },
        input, buttonId;

    // Overrides any of the default option values with any option values passed in during construction.
    qq.extend(options, o);

    buttonId = qq.getUniqueId();

    // Embed an opaque `<input type="file">` element as a child of `options.element`.
    function createInput() {
        var input = document.createElement("input");

        input.setAttribute(qq.UploadButton.BUTTON_ID_ATTR_NAME, buttonId);

        if (options.multiple) {
            input.setAttribute("multiple", "");
        }

        if (options.folders && qq.supportedFeatures.folderSelection) {
            // selecting directories is only possible in Chrome now, via a vendor-specific prefixed attribute
            input.setAttribute("webkitdirectory", "");
        }

        if (options.acceptFiles) {
            input.setAttribute("accept", options.acceptFiles);
        }

        input.setAttribute("type", "file");
        input.setAttribute("name", options.name);

        qq(input).css({
            position: "absolute",
            // in Opera only 'browse' button
            // is clickable and it is located at
            // the right side of the input
            right: 0,
            top: 0,
            fontFamily: "Arial",
            // 4 persons reported this, the max values that worked for them were 243, 236, 236, 118
            fontSize: "118px",
            margin: 0,
            padding: 0,
            cursor: "pointer",
            opacity: 0
        });

        options.element.appendChild(input);

        disposeSupport.attach(input, "change", function(){
            options.onChange(input);
        });

        // **These event handlers will be removed** in the future as the :hover CSS pseudo-class is available on all supported browsers
        disposeSupport.attach(input, "mouseover", function(){
            qq(options.element).addClass(options.hoverClass);
        });
        disposeSupport.attach(input, "mouseout", function(){
            qq(options.element).removeClass(options.hoverClass);
        });

        disposeSupport.attach(input, "focus", function(){
            qq(options.element).addClass(options.focusClass);
        });
        disposeSupport.attach(input, "blur", function(){
            qq(options.element).removeClass(options.focusClass);
        });

        // IE and Opera, unfortunately have 2 tab stops on file input
        // which is unacceptable in our case, disable keyboard access
        if (window.attachEvent) {
            // it is IE or Opera
            input.setAttribute("tabIndex", "-1");
        }

        return input;
    }

    // Make button suitable container for input
    qq(options.element).css({
        position: "relative",
        overflow: "hidden",
        // Make sure browse button is in the right side in Internet Explorer
        direction: "ltr"
    });

    input = createInput();


    // Exposed API
    qq.extend(this, {
        getInput: function() {
            return input;
        },

        getButtonId: function() {
            return buttonId;
        },

        setMultiple: function(isMultiple) {
            if (isMultiple !== options.multiple) {
                if (isMultiple) {
                    input.setAttribute("multiple", "");
                }
                else {
                    input.removeAttribute("multiple");
                }
            }
        },

        setAcceptFiles: function(acceptFiles) {
            if (acceptFiles !== options.acceptFiles) {
                input.setAttribute("accept", acceptFiles);
            }
        },

        reset: function(){
            if (input.parentNode){
                qq(input).remove();
            }

            qq(options.element).removeClass(options.focusClass);
            input = createInput();
        }
    });
};

qq.UploadButton.BUTTON_ID_ATTR_NAME = "qq-button-id";

/*globals qq */
qq.UploadData = function(uploaderProxy) {
    "use strict";

    var data = [],
        byUuid = {},
        byStatus = {};


    function getDataByIds(idOrIds) {
        if (qq.isArray(idOrIds)) {
            var entries = [];

            qq.each(idOrIds, function(idx, id) {
                entries.push(data[id]);
            });

            return entries;
        }

        return data[idOrIds];
    }

    function getDataByUuids(uuids) {
        if (qq.isArray(uuids)) {
            var entries = [];

            qq.each(uuids, function(idx, uuid) {
                entries.push(data[byUuid[uuid]]);
            });

            return entries;
        }

        return data[byUuid[uuids]];
    }

    function getDataByStatus(status) {
        var statusResults = [],
            statuses = [].concat(status);

        qq.each(statuses, function(index, statusEnum) {
            var statusResultIndexes = byStatus[statusEnum];

            if (statusResultIndexes !== undefined) {
                qq.each(statusResultIndexes, function(i, dataIndex) {
                    statusResults.push(data[dataIndex]);
                });
            }
        });

        return statusResults;
    }

    qq.extend(this, {
        /**
         * Adds a new file to the data cache for tracking purposes.
         *
         * @param uuid Initial UUID for this file.
         * @param name Initial name of this file.
         * @param size Size of this file, -1 if this cannot be determined
         * @param status Initial `qq.status` for this file.  If null/undefined, `qq.status.SUBMITTING`.
         * @returns {number} Internal ID for this file.
         */
        addFile: function(uuid, name, size, status) {
            status = status || qq.status.SUBMITTING;

            var id = data.push({
                name: name,
                originalName: name,
                uuid: uuid,
                size: size,
                status: status
            }) - 1;

            data[id].id = id;
            byUuid[uuid] = id;

            if (byStatus[status] === undefined) {
                byStatus[status] = [];
            }
            byStatus[status].push(id);

            uploaderProxy.onStatusChange(id, null, status);

            return id;
        },

        retrieve: function(optionalFilter) {
            if (qq.isObject(optionalFilter) && data.length)  {
                if (optionalFilter.id !== undefined) {
                    return getDataByIds(optionalFilter.id);
                }

                else if (optionalFilter.uuid !== undefined) {
                    return getDataByUuids(optionalFilter.uuid);
                }

                else if (optionalFilter.status) {
                    return getDataByStatus(optionalFilter.status);
                }
            }
            else {
                return qq.extend([], data, true);
            }
        },

        reset: function() {
            data = [];
            byUuid = {};
            byStatus = {};
        },

        setStatus: function(id, newStatus) {
            var oldStatus = data[id].status,
                byStatusOldStatusIndex = qq.indexOf(byStatus[oldStatus], id);

            byStatus[oldStatus].splice(byStatusOldStatusIndex, 1);

            data[id].status = newStatus;

            if (byStatus[newStatus] === undefined) {
                byStatus[newStatus] = [];
            }
            byStatus[newStatus].push(id);

            uploaderProxy.onStatusChange(id, oldStatus, newStatus);
        },

        uuidChanged: function(id, newUuid) {
            var oldUuid = data[id].uuid;

            data[id].uuid = newUuid;
            byUuid[newUuid] = id;
            delete byUuid[oldUuid];
        },

        updateName: function(id, newName) {
            data[id].name = newName;
        }
    });
};

qq.status = {
    SUBMITTING: "submitting",
    SUBMITTED: "submitted",
    REJECTED: "rejected",
    QUEUED: "queued",
    CANCELED: "canceled",
    PAUSED: "paused",
    UPLOADING: "uploading",
    UPLOAD_RETRYING: "retrying upload",
    UPLOAD_SUCCESSFUL: "upload successful",
    UPLOAD_FAILED: "upload failed",
    DELETE_FAILED: "delete failed",
    DELETING: "deleting",
    DELETED: "deleted"
};

/*globals qq*/
/**
 * Defines the public API for FineUploaderBasic mode.
 */
(function(){
    "use strict";

    qq.basePublicApi = {
        log: function(str, level) {
            if (this._options.debug && (!level || level === "info")) {
                qq.log("[FineUploader " + qq.version + "] " + str);
            }
            else if (level && level !== "info") {
                qq.log("[FineUploader " + qq.version + "] " + str, level);

            }
        },

        setParams: function(params, id) {
            /*jshint eqeqeq: true, eqnull: true*/
            if (id == null) {
                this._options.request.params = params;
            }
            else {
                this._paramsStore.setParams(params, id);
            }
        },

        setDeleteFileParams: function(params, id) {
            /*jshint eqeqeq: true, eqnull: true*/
            if (id == null) {
                this._options.deleteFile.params = params;
            }
            else {
                this._deleteFileParamsStore.setParams(params, id);
            }
        },

        // Re-sets the default endpoint, an endpoint for a specific file, or an endpoint for a specific button
        setEndpoint: function(endpoint, id) {
            /*jshint eqeqeq: true, eqnull: true*/
            if (id == null) {
                this._options.request.endpoint = endpoint;
            }
            else {
                this._endpointStore.setEndpoint(endpoint, id);
            }
        },

        getInProgress: function() {
            return this._uploadData.retrieve({
                status: [
                    qq.status.UPLOADING,
                    qq.status.UPLOAD_RETRYING,
                    qq.status.QUEUED
                ]
            }).length;
        },

        getNetUploads: function() {
            return this._netUploaded;
        },

        uploadStoredFiles: function() {
            var idToUpload;

            if (this._storedIds.length === 0) {
                this._itemError("noFilesError");
            }
            else {
                while (this._storedIds.length) {
                    idToUpload = this._storedIds.shift();
                    this._uploadFile(idToUpload);
                }
            }
        },

        clearStoredFiles: function(){
            this._storedIds = [];
        },

        retry: function(id) {
            return this._manualRetry(id);
        },

        cancel: function(id) {
            this._handler.cancel(id);
        },

        cancelAll: function() {
            var storedIdsCopy = [],
                self = this;

            qq.extend(storedIdsCopy, this._storedIds);
            qq.each(storedIdsCopy, function(idx, storedFileId) {
                self.cancel(storedFileId);
            });

            this._handler.cancelAll();
        },

        reset: function() {
            this.log("Resetting uploader...");

            this._handler.reset();
            this._storedIds = [];
            this._autoRetries = [];
            this._retryTimeouts = [];
            this._preventRetries = [];
            this._thumbnailUrls = [];

            qq.each(this._buttons, function(idx, button) {
                button.reset();
            });

            this._paramsStore.reset();
            this._endpointStore.reset();
            this._netUploadedOrQueued = 0;
            this._netUploaded = 0;
            this._uploadData.reset();
            this._buttonIdsForFileIds = [];

            this._pasteHandler && this._pasteHandler.reset();
            this._options.session.refreshOnReset && this._refreshSessionData();
        },

        addFiles: function(filesOrInputs, params, endpoint) {
            var verifiedFilesOrInputs = [],
                fileOrInputIndex, fileOrInput, fileIndex;

            if (filesOrInputs) {
                if (!qq.isFileList(filesOrInputs)) {
                    filesOrInputs = [].concat(filesOrInputs);
                }

                for (fileOrInputIndex = 0; fileOrInputIndex < filesOrInputs.length; fileOrInputIndex+=1) {
                    fileOrInput = filesOrInputs[fileOrInputIndex];

                    if (qq.isFileOrInput(fileOrInput)) {
                        if (qq.isInput(fileOrInput) && qq.supportedFeatures.ajaxUploading) {
                            for (fileIndex = 0; fileIndex < fileOrInput.files.length; fileIndex++) {
                                this._handleNewFile(fileOrInput.files[fileIndex], verifiedFilesOrInputs);
                            }
                        }
                        else {
                            this._handleNewFile(fileOrInput, verifiedFilesOrInputs);
                        }
                    }
                    else {
                        this.log(fileOrInput + " is not a File or INPUT element!  Ignoring!", "warn");
                    }
                }

                this.log("Received " + verifiedFilesOrInputs.length + " files or inputs.");
                this._prepareItemsForUpload(verifiedFilesOrInputs, params, endpoint);
            }
        },

        addBlobs: function(blobDataOrArray, params, endpoint) {
            if (blobDataOrArray) {
                var blobDataArray = [].concat(blobDataOrArray),
                    verifiedBlobDataList = [],
                    self = this;

                qq.each(blobDataArray, function(idx, blobData) {
                    var blobOrBlobData;

                    if (qq.isBlob(blobData) && !qq.isFileOrInput(blobData)) {
                        blobOrBlobData = {
                            blob: blobData,
                            name: self._options.blobs.defaultName
                        };
                    }
                    else if (qq.isObject(blobData) && blobData.blob && blobData.name) {
                        blobOrBlobData = blobData;
                    }
                    else {
                        self.log("addBlobs: entry at index " + idx + " is not a Blob or a BlobData object", "error");
                    }

                    blobOrBlobData && self._handleNewFile(blobOrBlobData, verifiedBlobDataList);
                });

                this._prepareItemsForUpload(verifiedBlobDataList, params, endpoint);
            }
            else {
                this.log("undefined or non-array parameter passed into addBlobs", "error");
            }
        },

        getUuid: function(id) {
            return this._uploadData.retrieve({id: id}).uuid;
        },

        setUuid: function(id, newUuid) {
            return this._uploadData.uuidChanged(id, newUuid);
        },

        getResumableFilesData: function() {
            return this._handler.getResumableFilesData();
        },

        getSize: function(id) {
            return this._uploadData.retrieve({id: id}).size;
        },

        getName: function(id) {
            return this._uploadData.retrieve({id: id}).name;
        },

        setName: function(id, newName) {
            this._uploadData.updateName(id, newName);
        },

        getFile: function(fileOrBlobId) {
            return this._handler.getFile(fileOrBlobId);
        },

        deleteFile: function(id) {
            this._onSubmitDelete(id);
        },

        setDeleteFileEndpoint: function(endpoint, id) {
            /*jshint eqeqeq: true, eqnull: true*/
            if (id == null) {
                this._options.deleteFile.endpoint = endpoint;
            }
            else {
                this._deleteFileEndpointStore.setEndpoint(endpoint, id);
            }
        },

        doesExist: function(fileOrBlobId) {
            return this._handler.isValid(fileOrBlobId);
        },

        getUploads: function(optionalFilter) {
            return this._uploadData.retrieve(optionalFilter);
        },

        getButton: function(fileId) {
            return this._getButton(this._buttonIdsForFileIds[fileId]);
        },

        // Generate a variable size thumbnail on an img or canvas,
        // returning a promise that is fulfilled when the attempt completes.
        // Thumbnail can either be based off of a URL for an image returned
        // by the server in the upload response, or the associated `Blob`.
        drawThumbnail: function(fileId, imgOrCanvas, maxSize, fromServer) {
            if (this._imageGenerator) {
                var fileOrUrl = this._thumbnailUrls[fileId],
                    options = {
                        scale: maxSize > 0,
                        maxSize: maxSize > 0 ? maxSize : null
                    };

                // If client-side preview generation is possible
                // and we are not specifically looking for the image URl returned by the server...
                if (!fromServer && qq.supportedFeatures.imagePreviews) {
                    fileOrUrl = this.getFile(fileId);
                }

                /* jshint eqeqeq:false,eqnull:true */
                if (fileOrUrl == null) {
                    return new qq.Promise().failure(imgOrCanvas, "File or URL not found.");
                }

                return this._imageGenerator.generate(fileOrUrl, imgOrCanvas, options);
            }
        },

        pauseUpload: function(id) {
            var uploadData = this._uploadData.retrieve({id: id});

            if (!qq.supportedFeatures.pause || !this._options.chunking.enabled) {
                return false;
            }

            // Pause only really makes sense if the file is uploading or retrying
            if (qq.indexOf([qq.status.UPLOADING, qq.status.UPLOAD_RETRYING], uploadData.status) >= 0) {
                if (this._handler.pause(id)) {
                    this._uploadData.setStatus(id, qq.status.PAUSED);
                    return true;
                }
                else {
                    qq.log(qq.format("Unable to pause file ID {} ({}).", id, this.getName(id)), "error");
                }
            }
            else {
                qq.log(qq.format("Ignoring pause for file ID {} ({}).  Not in progress.", id, this.getName(id)), "error");
            }

            return false;
        },

        continueUpload: function(id) {
            var uploadData = this._uploadData.retrieve({id: id});

            if (!qq.supportedFeatures.pause || !this._options.chunking.enabled) {
                return false;
            }

            if (uploadData.status === qq.status.PAUSED) {
                qq.log(qq.format("Paused file ID {} ({}) will be continued.  Not paused.", id, this.getName(id)));
                this._uploadFile(id);
                return true;
            }
            else {
                qq.log(qq.format("Ignoring continue for file ID {} ({}).  Not paused.", id, this.getName(id)), "error");
            }

            return false;
        },

        getRemainingAllowedItems: function() {
            var allowedItems = this._options.validation.itemLimit;

            if (allowedItems > 0) {
                return this._options.validation.itemLimit - this._netUploadedOrQueued;
            }

            return null;
        }
    };




    /**
     * Defines the private (internal) API for FineUploaderBasic mode.
     */
    qq.basePrivateApi = {
        _uploadFile: function(id) {
            if (!this._handler.upload(id)) {
                this._uploadData.setStatus(id, qq.status.QUEUED);
            }
        },

        // Attempts to refresh session data only if the `qq.Session` module exists
        // and a session endpoint has been specified.  The `onSessionRequestComplete`
        // callback will be invoked once the refresh is complete.
        _refreshSessionData: function() {
            var self = this,
                options = this._options.session;

            /* jshint eqnull:true */
            if (qq.Session && this._options.session.endpoint != null) {
                if (!this._session) {
                    qq.extend(options, this._options.cors);

                    options.log = qq.bind(this.log, this);
                    options.addFileRecord = qq.bind(this._addCannedFile, this);

                    this._session = new qq.Session(options);
                }

                setTimeout(function() {
                    self._session.refresh().then(function(response, xhrOrXdr) {

                        self._options.callbacks.onSessionRequestComplete(response, true, xhrOrXdr);

                    }, function(response, xhrOrXdr) {

                        self._options.callbacks.onSessionRequestComplete(response, false, xhrOrXdr);
                    });
                }, 0);
            }
        },

        // Updates internal state with a file record (not backed by a live file).  Returns the assigned ID.
        _addCannedFile: function(sessionData) {
            var id = this._uploadData.addFile(sessionData.uuid, sessionData.name, sessionData.size,
                qq.status.UPLOAD_SUCCESSFUL);

            sessionData.deleteFileEndpoint && this.setDeleteFileEndpoint(sessionData.deleteFileEndpoint, id);
            sessionData.deleteFileParams && this.setDeleteFileParams(sessionData.deleteFileParams, id);

            if (sessionData.thumbnailUrl) {
                this._thumbnailUrls[id] = sessionData.thumbnailUrl;
            }

            this._netUploaded++;
            this._netUploadedOrQueued++;

            return id;
        },

        // Updates internal state when a new file has been received, and adds it along with its ID to a passed array.
        _handleNewFile: function(file, newFileWrapperList) {
            var size = -1,
                uuid = qq.getUniqueId(),
                name = qq.getFilename(file),
                id;

            if (file.size >= 0) {
                size = file.size;
            }
            else if (file.blob) {
                size = file.blob.size;
            }

            id = this._uploadData.addFile(uuid, name, size);
            this._handler.add(id, file);

            this._netUploadedOrQueued++;

            newFileWrapperList.push({id: id, file: file});
        },

        // Creates an internal object that tracks various properties of each extra button,
        // and then actually creates the extra button.
        _generateExtraButtonSpecs: function() {
            var self = this;

            this._extraButtonSpecs = {};

            qq.each(this._options.extraButtons, function(idx, extraButtonOptionEntry) {
                var multiple = extraButtonOptionEntry.multiple,
                    validation = qq.extend({}, self._options.validation, true),
                    extraButtonSpec = qq.extend({}, extraButtonOptionEntry);

                if (multiple === undefined) {
                    multiple = self._options.multiple;
                }

                if (extraButtonSpec.validation) {
                    qq.extend(validation, extraButtonOptionEntry.validation, true);
                }

                qq.extend(extraButtonSpec, {
                    multiple: multiple,
                    validation: validation
                }, true);

                self._initExtraButton(extraButtonSpec);
            });
        },

        // Creates an extra button element
        _initExtraButton: function(spec) {
            var button = this._createUploadButton({
                element: spec.element,
                multiple: spec.multiple,
                accept: spec.validation.acceptFiles,
                folders: spec.folders,
                allowedExtensions: spec.validation.allowedExtensions
            });

            this._extraButtonSpecs[button.getButtonId()] = spec;
        },

        /**
         * Gets the internally used tracking ID for a button.
         *
         * @param buttonOrFileInputOrFile `File`, `<input type="file">`, or a button container element
         * @returns {*} The button's ID, or undefined if no ID is recoverable
         * @private
         */
        _getButtonId: function(buttonOrFileInputOrFile) {
            var inputs, fileInput;

            // If the item is a `Blob` it will never be associated with a button or drop zone.
            if (buttonOrFileInputOrFile && !buttonOrFileInputOrFile.blob && !qq.isBlob(buttonOrFileInputOrFile)) {
                if (qq.isFile(buttonOrFileInputOrFile)) {
                    return buttonOrFileInputOrFile.qqButtonId;
                }
                else if (buttonOrFileInputOrFile.tagName.toLowerCase() === "input" &&
                    buttonOrFileInputOrFile.type.toLowerCase() === "file") {

                    return buttonOrFileInputOrFile.getAttribute(qq.UploadButton.BUTTON_ID_ATTR_NAME);
                }

                inputs = buttonOrFileInputOrFile.getElementsByTagName("input");

                qq.each(inputs, function(idx, input) {
                    if (input.getAttribute("type") === "file") {
                        fileInput = input;
                        return false;
                    }
                });

                if (fileInput) {
                    return fileInput.getAttribute(qq.UploadButton.BUTTON_ID_ATTR_NAME);
                }
            }
        },

        _annotateWithButtonId: function(file, associatedInput) {
            if (qq.isFile(file)) {
                file.qqButtonId = this._getButtonId(associatedInput);
            }
        },

        _getButton: function(buttonId) {
            var extraButtonsSpec = this._extraButtonSpecs[buttonId];

            if (extraButtonsSpec) {
                return extraButtonsSpec.element;
            }
            else if (buttonId === this._defaultButtonId) {
                return this._options.button;
            }
        },

        _handleCheckedCallback: function(details) {
            var self = this,
                callbackRetVal = details.callback();

            if (callbackRetVal instanceof qq.Promise) {
                this.log(details.name + " - waiting for " + details.name + " promise to be fulfilled for " + details.identifier);
                return callbackRetVal.then(
                    function(successParam) {
                        self.log(details.name + " promise success for " + details.identifier);
                        details.onSuccess(successParam);
                    },
                    function() {
                        if (details.onFailure) {
                            self.log(details.name + " promise failure for " + details.identifier);
                            details.onFailure();
                        }
                        else {
                            self.log(details.name + " promise failure for " + details.identifier);
                        }
                    });
            }

            if (callbackRetVal !== false) {
                details.onSuccess(callbackRetVal);
            }
            else {
                if (details.onFailure) {
                    this.log(details.name + " - return value was 'false' for " + details.identifier + ".  Invoking failure callback.");
                    details.onFailure();
                }
                else {
                    this.log(details.name + " - return value was 'false' for " + details.identifier + ".  Will not proceed.");
                }
            }

            return callbackRetVal;
        },

        /**
         * Generate a tracked upload button.
         *
         * @param spec Object containing a required `element` property
         * along with optional `multiple`, `accept`, and `folders`.
         * @returns {qq.UploadButton}
         * @private
         */
        _createUploadButton: function(spec) {
            var self = this,
                acceptFiles = spec.accept || this._options.validation.acceptFiles,
                allowedExtensions = spec.allowedExtensions || this._options.validation.allowedExtensions;

            function allowMultiple() {
                if (qq.supportedFeatures.ajaxUploading) {
                    // Workaround for bug in iOS7 (see #1039)
                    if (qq.ios7() && self._isAllowedExtension(allowedExtensions, ".mov")) {
                        return false;
                    }

                    if (spec.multiple === undefined) {
                        return self._options.multiple;
                    }

                    return spec.multiple;
                }

                return false;
            }

            var button = new qq.UploadButton({
                element: spec.element,
                folders: spec.folders,
                name: this._options.request.inputName,
                multiple: allowMultiple(),
                acceptFiles: acceptFiles,
                onChange: function(input) {
                    self._onInputChange(input);
                },
                hoverClass: this._options.classes.buttonHover,
                focusClass: this._options.classes.buttonFocus
            });

            this._disposeSupport.addDisposer(function() {
                button.dispose();
            });

            self._buttons.push(button);

            return button;
        },

        _createUploadHandler: function(additionalOptions, namespace) {
            var self = this,
                options = {
                    debug: this._options.debug,
                    maxConnections: this._options.maxConnections,
                    cors: this._options.cors,
                    demoMode: this._options.demoMode,
                    paramsStore: this._paramsStore,
                    endpointStore: this._endpointStore,
                    chunking: this._options.chunking,
                    resume: this._options.resume,
                    blobs: this._options.blobs,
                    log: qq.bind(self.log, self),
                    onProgress: function(id, name, loaded, total){
                        self._onProgress(id, name, loaded, total);
                        self._options.callbacks.onProgress(id, name, loaded, total);
                    },
                    onComplete: function(id, name, result, xhr){
                        var retVal = self._onComplete(id, name, result, xhr);

                        // If the internal `_onComplete` handler returns a promise, don't invoke the `onComplete` callback
                        // until the promise has been fulfilled.
                        if (retVal instanceof  qq.Promise) {
                            retVal.done(function() {
                                self._options.callbacks.onComplete(id, name, result, xhr);
                            });
                        }
                        else {
                            self._options.callbacks.onComplete(id, name, result, xhr);
                        }
                    },
                    onCancel: function(id, name) {
                        return self._handleCheckedCallback({
                            name: "onCancel",
                            callback: qq.bind(self._options.callbacks.onCancel, self, id, name),
                            onSuccess: qq.bind(self._onCancel, self, id, name),
                            identifier: id
                        });
                    },
                    onUpload: function(id, name) {
                        self._onUpload(id, name);
                        self._options.callbacks.onUpload(id, name);
                    },
                    onUploadChunk: function(id, name, chunkData) {
                        self._onUploadChunk(id, chunkData);
                        self._options.callbacks.onUploadChunk(id, name, chunkData);
                    },
                    onUploadChunkSuccess: function(id, chunkData, result, xhr) {
                        self._options.callbacks.onUploadChunkSuccess.apply(self, arguments);
                    },
                    onResume: function(id, name, chunkData) {
                        return self._options.callbacks.onResume(id, name, chunkData);
                    },
                    onAutoRetry: function(id, name, responseJSON, xhr) {
                        return self._onAutoRetry.apply(self, arguments);
                    },
                    onUuidChanged: function(id, newUuid) {
                        self.log("Server requested UUID change from '" + self.getUuid(id) + "' to '" + newUuid + "'");
                        self.setUuid(id, newUuid);
                    },
                    getName: qq.bind(self.getName, self),
                    getUuid: qq.bind(self.getUuid, self),
                    getSize: qq.bind(self.getSize, self)
                };

            qq.each(this._options.request, function(prop, val) {
                options[prop] = val;
            });

            if (additionalOptions) {
                qq.each(additionalOptions, function(key, val) {
                    options[key] = val;
                });
            }

            return new qq.UploadHandler(options, namespace);
        },

        _createDeleteHandler: function() {
            var self = this;

            return new qq.DeleteFileAjaxRequester({
                method: this._options.deleteFile.method.toUpperCase(),
                maxConnections: this._options.maxConnections,
                uuidParamName: this._options.request.uuidName,
                customHeaders: this._options.deleteFile.customHeaders,
                paramsStore: this._deleteFileParamsStore,
                endpointStore: this._deleteFileEndpointStore,
                demoMode: this._options.demoMode,
                cors: this._options.cors,
                log: qq.bind(self.log, self),
                onDelete: function(id) {
                    self._onDelete(id);
                    self._options.callbacks.onDelete(id);
                },
                onDeleteComplete: function(id, xhrOrXdr, isError) {
                    self._onDeleteComplete(id, xhrOrXdr, isError);
                    self._options.callbacks.onDeleteComplete(id, xhrOrXdr, isError);
                }

            });
        },

        _createPasteHandler: function() {
            var self = this;

            return new qq.PasteSupport({
                targetElement: this._options.paste.targetElement,
                callbacks: {
                    log: qq.bind(self.log, self),
                    pasteReceived: function(blob) {
                        self._handleCheckedCallback({
                            name: "onPasteReceived",
                            callback: qq.bind(self._options.callbacks.onPasteReceived, self, blob),
                            onSuccess: qq.bind(self._handlePasteSuccess, self, blob),
                            identifier: "pasted image"
                        });
                    }
                }
            });
        },

        _createUploadDataTracker: function() {
            var self = this;

            return new qq.UploadData({
                getName: function(id) {
                    return self.getName(id);
                },
                getUuid: function(id) {
                    return self.getUuid(id);
                },
                getSize: function(id) {
                    return self.getSize(id);
                },
                onStatusChange: function(id, oldStatus, newStatus) {
                    self._onUploadStatusChange(id, oldStatus, newStatus);
                    self._options.callbacks.onStatusChange(id, oldStatus, newStatus);
                }
            });
        },

        _onUploadStatusChange: function(id, oldStatus, newStatus) {
            // Make sure a "queued" retry attempt is canceled if the upload has been paused
            if (newStatus === qq.status.PAUSED) {
                clearTimeout(this._retryTimeouts[id]);
            }
        },

        _handlePasteSuccess: function(blob, extSuppliedName) {
            var extension = blob.type.split("/")[1],
                name = extSuppliedName;

            /*jshint eqeqeq: true, eqnull: true*/
            if (name == null) {
                name = this._options.paste.defaultName;
            }

            name += "." + extension;

            this.addBlobs({
                name: name,
                blob: blob
            });
        },

        _preventLeaveInProgress: function(){
            var self = this;

            this._disposeSupport.attach(window, "beforeunload", function(e){
                if (self.getInProgress()) {
                    e = e || window.event;
                    // for ie, ff
                    e.returnValue = self._options.messages.onLeave;
                    // for webkit
                    return self._options.messages.onLeave;
                }
            });
        },

        _onSubmit: function(id, name) {
            //nothing to do yet in core uploader
        },

        _onProgress: function(id, name, loaded, total) {
            //nothing to do yet in core uploader
        },

        _onComplete: function(id, name, result, xhr) {
            if (!result.success) {
                this._netUploadedOrQueued--;
                this._uploadData.setStatus(id, qq.status.UPLOAD_FAILED);
            }
            else {
                if (result.thumbnailUrl) {
                    this._thumbnailUrls[id] = result.thumbnailUrl;
                }

                this._netUploaded++;
                this._uploadData.setStatus(id, qq.status.UPLOAD_SUCCESSFUL);
            }

            this._maybeParseAndSendUploadError(id, name, result, xhr);

            return result.success ? true : false;
        },

        _onCancel: function(id, name) {
            this._netUploadedOrQueued--;

            clearTimeout(this._retryTimeouts[id]);

            var storedItemIndex = qq.indexOf(this._storedIds, id);
            if (!this._options.autoUpload && storedItemIndex >= 0) {
                this._storedIds.splice(storedItemIndex, 1);
            }

            this._uploadData.setStatus(id, qq.status.CANCELED);
        },

        _isDeletePossible: function() {
            if (!qq.DeleteFileAjaxRequester || !this._options.deleteFile.enabled) {
                return false;
            }

            if (this._options.cors.expected) {
                if (qq.supportedFeatures.deleteFileCorsXhr) {
                    return true;
                }

                if (qq.supportedFeatures.deleteFileCorsXdr && this._options.cors.allowXdr) {
                    return true;
                }

                return false;
            }

            return true;
        },

        _onSubmitDelete: function(id, onSuccessCallback, additionalMandatedParams) {
            var uuid = this.getUuid(id),
                adjustedOnSuccessCallback;

            if (onSuccessCallback) {
                adjustedOnSuccessCallback = qq.bind(onSuccessCallback, this, id, uuid, additionalMandatedParams);
            }

            if (this._isDeletePossible()) {
                return this._handleCheckedCallback({
                    name: "onSubmitDelete",
                    callback: qq.bind(this._options.callbacks.onSubmitDelete, this, id),
                    onSuccess: adjustedOnSuccessCallback ||
                        qq.bind(this._deleteHandler.sendDelete, this, id, uuid, additionalMandatedParams),
                    identifier: id
                });
            }
            else {
                this.log("Delete request ignored for ID " + id + ", delete feature is disabled or request not possible " +
                    "due to CORS on a user agent that does not support pre-flighting.", "warn");
                return false;
            }
        },

        _onDelete: function(id) {
            this._uploadData.setStatus(id, qq.status.DELETING);
        },

        _onDeleteComplete: function(id, xhrOrXdr, isError) {
            var name = this.getName(id);

            if (isError) {
                this._uploadData.setStatus(id, qq.status.DELETE_FAILED);
                this.log("Delete request for '" + name + "' has failed.", "error");

                // For error reporing, we only have accesss to the response status if this is not
                // an `XDomainRequest`.
                if (xhrOrXdr.withCredentials === undefined) {
                    this._options.callbacks.onError(id, name, "Delete request failed", xhrOrXdr);
                }
                else {
                    this._options.callbacks.onError(id, name, "Delete request failed with response code " + xhrOrXdr.status, xhrOrXdr);
                }
            }
            else {
                this._netUploadedOrQueued--;
                this._netUploaded--;
                this._handler.expunge(id);
                this._uploadData.setStatus(id, qq.status.DELETED);
                this.log("Delete request for '" + name + "' has succeeded.");
            }
        },

        _onUpload: function(id, name) {
            this._uploadData.setStatus(id, qq.status.UPLOADING);
        },

        _onUploadChunk: function(id, chunkData) {
            //nothing to do in the base uploader
        },

        _onInputChange: function(input) {
            var fileIndex;

            if (qq.supportedFeatures.ajaxUploading) {
                for (fileIndex = 0; fileIndex < input.files.length; fileIndex++) {
                    this._annotateWithButtonId(input.files[fileIndex], input);
                }

                this.addFiles(input.files);
            }
            // Android 2.3.x will fire `onchange` even if no file has been selected
            else if (input.value.length > 0) {
                this.addFiles(input);
            }

            qq.each(this._buttons, function(idx, button) {
                button.reset();
            });
        },

        _onBeforeAutoRetry: function(id, name) {
            this.log("Waiting " + this._options.retry.autoAttemptDelay + " seconds before retrying " + name + "...");
        },

        /**
         * Attempt to automatically retry a failed upload.
         *
         * @param id The file ID of the failed upload
         * @param name The name of the file associated with the failed upload
         * @param responseJSON Response from the server, parsed into a javascript object
         * @param xhr Ajax transport used to send the failed request
         * @param callback Optional callback to be invoked if a retry is prudent.
         * Invoked in lieu of asking the upload handler to retry.
         * @returns {boolean} true if an auto-retry will occur
         * @private
         */
        _onAutoRetry: function(id, name, responseJSON, xhr, callback) {
            var self = this;

            self._preventRetries[id] = responseJSON[self._options.retry.preventRetryResponseProperty];

            if (self._shouldAutoRetry(id, name, responseJSON)) {
                self._maybeParseAndSendUploadError.apply(self, arguments);
                self._options.callbacks.onAutoRetry(id, name, self._autoRetries[id] + 1);
                self._onBeforeAutoRetry(id, name);

                self._retryTimeouts[id] = setTimeout(function() {
                    self.log("Retrying " + name + "...");
                    self._autoRetries[id]++;
                    self._uploadData.setStatus(id, qq.status.UPLOAD_RETRYING);

                    if (callback) {
                        callback(id);
                    }
                    else {
                        self._handler.retry(id);
                    }
                }, self._options.retry.autoAttemptDelay * 1000);

                return true;
            }
        },

        _shouldAutoRetry: function(id, name, responseJSON) {
            var uploadData = this._uploadData.retrieve({id: id});

            /*jshint laxbreak: true */
            if (!this._preventRetries[id]
                && this._options.retry.enableAuto
                && uploadData.status !== qq.status.PAUSED) {

                if (this._autoRetries[id] === undefined) {
                    this._autoRetries[id] = 0;
                }

                return this._autoRetries[id] < this._options.retry.maxAutoAttempts;
            }

            return false;
        },

        //return false if we should not attempt the requested retry
        _onBeforeManualRetry: function(id) {
            var itemLimit = this._options.validation.itemLimit;

            if (this._preventRetries[id]) {
                this.log("Retries are forbidden for id " + id, "warn");
                return false;
            }
            else if (this._handler.isValid(id)) {
                var fileName = this.getName(id);

                if (this._options.callbacks.onManualRetry(id, fileName) === false) {
                    return false;
                }

                if (itemLimit > 0 && this._netUploadedOrQueued+1 > itemLimit) {
                    this._itemError("retryFailTooManyItems");
                    return false;
                }

                this.log("Retrying upload for '" + fileName + "' (id: " + id + ")...");
                return true;
            }
            else {
                this.log("'" + id + "' is not a valid file ID", "error");
                return false;
            }
        },

        /**
         * Conditionally orders a manual retry of a failed upload.
         *
         * @param id File ID of the failed upload
         * @param callback Optional callback to invoke if a retry is prudent.
         * In lieu of asking the upload handler to retry.
         * @returns {boolean} true if a manual retry will occur
         * @private
         */
        _manualRetry: function(id, callback) {
            if (this._onBeforeManualRetry(id)) {
                this._netUploadedOrQueued++;
                this._uploadData.setStatus(id, qq.status.UPLOAD_RETRYING);

                if (callback) {
                    callback(id);
                }
                else {
                    this._handler.retry(id);
                }

                return true;
            }
        },

        _maybeParseAndSendUploadError: function(id, name, response, xhr) {
            // Assuming no one will actually set the response code to something other than 200
            // and still set 'success' to true...
            if (!response.success){
                if (xhr && xhr.status !== 200 && !response.error) {
                    this._options.callbacks.onError(id, name, "XHR returned response code " + xhr.status, xhr);
                }
                else {
                    var errorReason = response.error ? response.error : this._options.text.defaultResponseError;
                    this._options.callbacks.onError(id, name, errorReason, xhr);
                }
            }
        },

        _prepareItemsForUpload: function(items, params, endpoint) {
            var validationDescriptors = this._getValidationDescriptors(items),
                buttonId = this._getButtonId(items[0].file),
                button = this._getButton(buttonId);

            this._handleCheckedCallback({
                name: "onValidateBatch",
                callback: qq.bind(this._options.callbacks.onValidateBatch, this, validationDescriptors, button),
                onSuccess: qq.bind(this._onValidateBatchCallbackSuccess, this, validationDescriptors, items, params, endpoint, button),
                onFailure: qq.bind(this._onValidateBatchCallbackFailure, this, items),
                identifier: "batch validation"
            });
        },

        _upload: function(id, params, endpoint) {
            var name = this.getName(id);

            if (params) {
                this.setParams(params, id);
            }

            if (endpoint) {
                this.setEndpoint(endpoint, id);
            }

            this._handleCheckedCallback({
                name: "onSubmit",
                callback: qq.bind(this._options.callbacks.onSubmit, this, id, name),
                onSuccess: qq.bind(this._onSubmitCallbackSuccess, this, id, name),
                onFailure: qq.bind(this._fileOrBlobRejected, this, id, name),
                identifier: id
            });
        },

        _onSubmitCallbackSuccess: function(id, name) {
            var buttonId;

            if (qq.supportedFeatures.ajaxUploading) {
                buttonId = this._handler.getFile(id).qqButtonId;
            }
            else {
                buttonId = this._getButtonId(this._handler.getInput(id));
            }

            if (buttonId) {
                this._buttonIdsForFileIds[id] = buttonId;
            }

            this._onSubmit.apply(this, arguments);
            this._uploadData.setStatus(id, qq.status.SUBMITTED);
            this._onSubmitted.apply(this, arguments);
            this._options.callbacks.onSubmitted.apply(this, arguments);

            if (this._options.autoUpload) {
                this._uploadFile(id);
            }
            else {
                this._storeForLater(id);
            }
        },

        _onSubmitted: function(id) {
            //nothing to do in the base uploader
        },

        _storeForLater: function(id) {
            this._storedIds.push(id);
        },

        _onValidateBatchCallbackSuccess: function(validationDescriptors, items, params, endpoint, button) {
            var errorMessage,
                itemLimit = this._options.validation.itemLimit,
                proposedNetFilesUploadedOrQueued = this._netUploadedOrQueued;

            if (itemLimit === 0 || proposedNetFilesUploadedOrQueued <= itemLimit) {
                if (items.length > 0) {
                    this._handleCheckedCallback({
                        name: "onValidate",
                        callback: qq.bind(this._options.callbacks.onValidate, this, validationDescriptors[0], button),
                        onSuccess: qq.bind(this._onValidateCallbackSuccess, this, items, 0, params, endpoint),
                        onFailure: qq.bind(this._onValidateCallbackFailure, this, items, 0, params, endpoint),
                        identifier: "Item '" + items[0].file.name + "', size: " + items[0].file.size
                    });
                }
                else {
                    this._itemError("noFilesError");
                }
            }
            else {
                this._onValidateBatchCallbackFailure(items);
                errorMessage = this._options.messages.tooManyItemsError
                    .replace(/\{netItems\}/g, proposedNetFilesUploadedOrQueued)
                    .replace(/\{itemLimit\}/g, itemLimit);
                this._batchError(errorMessage);
            }
        },

        _onValidateBatchCallbackFailure: function(fileWrappers) {
            var self = this;

            qq.each(fileWrappers, function(idx, fileWrapper) {
                self._fileOrBlobRejected(fileWrapper.id);
            });
        },

        _onValidateCallbackSuccess: function(items, index, params, endpoint) {
            var self = this,
                nextIndex = index+1,
                validationDescriptor = this._getValidationDescriptor(items[index].file);

            this._validateFileOrBlobData(items[index], validationDescriptor)
                .then(
                    function() {
                        self._upload(items[index].id, params, endpoint);
                        self._maybeProcessNextItemAfterOnValidateCallback(true, items, nextIndex, params, endpoint);
                    },
                    function() {
                        self._maybeProcessNextItemAfterOnValidateCallback(false, items, nextIndex, params, endpoint);
                    }
                );
        },

        _onValidateCallbackFailure: function(items, index, params, endpoint) {
            var nextIndex = index+ 1;

            this._fileOrBlobRejected(items[0].id, items[0].file.name);

            this._maybeProcessNextItemAfterOnValidateCallback(false, items, nextIndex, params, endpoint);
        },

        _maybeProcessNextItemAfterOnValidateCallback: function(validItem, items, index, params, endpoint) {
            var self = this;

            if (items.length > index) {
                if (validItem || !this._options.validation.stopOnFirstInvalidFile) {
                    //use setTimeout to prevent a stack overflow with a large number of files in the batch & non-promissory callbacks
                    setTimeout(function() {
                        var validationDescriptor = self._getValidationDescriptor(items[index].file);

                        self._handleCheckedCallback({
                            name: "onValidate",
                            callback: qq.bind(self._options.callbacks.onValidate, self, items[index].file),
                            onSuccess: qq.bind(self._onValidateCallbackSuccess, self, items, index, params, endpoint),
                            onFailure: qq.bind(self._onValidateCallbackFailure, self, items, index, params, endpoint),
                            identifier: "Item '" + validationDescriptor.name + "', size: " + validationDescriptor.size
                        });
                    }, 0);
                }
                else if (!validItem) {
                    for (; index < items.length; index++) {
                        self._fileOrBlobRejected(items[index].id);
                    }
                }
            }
        },

        /**
         * Performs some internal validation checks on an item, defined in the `validation` option.
         *
         * @param fileWrapper Wrapper containing a `file` along with an `id`
         * @param validationDescriptor Normalized information about the item (`size`, `name`).
         * @returns qq.Promise with appropriate callbacks invoked depending on the validity of the file
         * @private
         */
        _validateFileOrBlobData: function(fileWrapper, validationDescriptor) {
            var self = this,
                file = fileWrapper.file,
                name = validationDescriptor.name,
                size = validationDescriptor.size,
                buttonId = this._getButtonId(file),
                validationBase = this._getValidationBase(buttonId),
                validityChecker = new qq.Promise();

            validityChecker.then(
                function() {},
                function() {
                    self._fileOrBlobRejected(fileWrapper.id, name);
                });

            if (qq.isFileOrInput(file) && !this._isAllowedExtension(validationBase.allowedExtensions, name)) {
                this._itemError("typeError", name, file);
                return validityChecker.failure();
            }

            if (size === 0) {
                this._itemError("emptyError", name, file);
                return validityChecker.failure();
            }

            if (size && validationBase.sizeLimit && size > validationBase.sizeLimit) {
                this._itemError("sizeError", name, file);
                return validityChecker.failure();
            }

            if (size && size < validationBase.minSizeLimit) {
                this._itemError("minSizeError", name, file);
                return validityChecker.failure();
            }

            if (qq.ImageValidation && qq.supportedFeatures.imagePreviews && qq.isFile(file)) {
                new qq.ImageValidation(file, qq.bind(self.log, self)).validate(validationBase.image).then(
                    validityChecker.success,
                    function(errorCode) {
                        self._itemError(errorCode + "ImageError", name, file);
                        validityChecker.failure();
                    }
                );
            }
            else {
                validityChecker.success();
            }

            return validityChecker;
        },

        _fileOrBlobRejected: function(id) {
            this._netUploadedOrQueued--;
            this._uploadData.setStatus(id, qq.status.REJECTED);
        },

        /**
         * Constructs and returns a message that describes an item/file error.  Also calls `onError` callback.
         *
         * @param code REQUIRED - a code that corresponds to a stock message describing this type of error
         * @param maybeNameOrNames names of the items that have failed, if applicable
         * @param item `File`, `Blob`, or `<input type="file">`
         * @private
         */
        _itemError: function(code, maybeNameOrNames, item) {
            var message = this._options.messages[code],
                allowedExtensions = [],
                names = [].concat(maybeNameOrNames),
                name = names[0],
                buttonId = this._getButtonId(item),
                validationBase = this._getValidationBase(buttonId),
                extensionsForMessage, placeholderMatch;

            function r(name, replacement){ message = message.replace(name, replacement); }

            qq.each(validationBase.allowedExtensions, function(idx, allowedExtension) {
                    /**
                     * If an argument is not a string, ignore it.  Added when a possible issue with MooTools hijacking the
                     * `allowedExtensions` array was discovered.  See case #735 in the issue tracker for more details.
                     */
                if (qq.isString(allowedExtension)) {
                    allowedExtensions.push(allowedExtension);
                }
            });

            extensionsForMessage = allowedExtensions.join(", ").toLowerCase();

            r("{file}", this._options.formatFileName(name));
            r("{extensions}", extensionsForMessage);
            r("{sizeLimit}", this._formatSize(validationBase.sizeLimit));
            r("{minSizeLimit}", this._formatSize(validationBase.minSizeLimit));

            placeholderMatch = message.match(/(\{\w+\})/g);
            if (placeholderMatch !== null) {
                qq.each(placeholderMatch, function(idx, placeholder) {
                    r(placeholder, names[idx]);
                });
            }

            this._options.callbacks.onError(null, name, message, undefined);

            return message;
        },

        _batchError: function(message) {
            this._options.callbacks.onError(null, null, message, undefined);
        },

        _isAllowedExtension: function(allowed, fileName) {
            var valid = false;

            if (!allowed.length) {
                return true;
            }

            qq.each(allowed, function(idx, allowedExt) {
                /**
                 * If an argument is not a string, ignore it.  Added when a possible issue with MooTools hijacking the
                 * `allowedExtensions` array was discovered.  See case #735 in the issue tracker for more details.
                 */
                if (qq.isString(allowedExt)) {
                    /*jshint eqeqeq: true, eqnull: true*/
                    var extRegex = new RegExp("\\." + allowedExt + "$", "i");

                    if (fileName.match(extRegex) != null) {
                        valid = true;
                        return false;
                    }
                }
            });

            return valid;
        },

        _formatSize: function(bytes){
            var i = -1;
            do {
                bytes = bytes / 1000;
                i++;
            } while (bytes > 999);

            return Math.max(bytes, 0.1).toFixed(1) + this._options.text.sizeSymbols[i];
        },

        _wrapCallbacks: function() {
            var self, safeCallback;

            self = this;

            safeCallback = function(name, callback, args) {
                var errorMsg;

                try {
                    return callback.apply(self, args);
                }
                catch (exception) {
                    errorMsg = exception.message || exception.toString();
                    self.log("Caught exception in '" + name + "' callback - " + errorMsg, "error");
                }
            };

            /* jshint forin: false, loopfunc: true */
            for (var prop in this._options.callbacks) {
                (function() {
                    var callbackName, callbackFunc;
                    callbackName = prop;
                    callbackFunc = self._options.callbacks[callbackName];
                    self._options.callbacks[callbackName] = function() {
                        return safeCallback(callbackName, callbackFunc, arguments);
                    };
                }());
            }
        },

        _parseFileOrBlobDataName: function(fileOrBlobData) {
            var name;

            if (qq.isFileOrInput(fileOrBlobData)) {
                if (fileOrBlobData.value) {
                    // it is a file input
                    // get input value and remove path to normalize
                    name = fileOrBlobData.value.replace(/.*(\/|\\)/, "");
                } else {
                    // fix missing properties in Safari 4 and firefox 11.0a2
                    name = (fileOrBlobData.fileName !== null && fileOrBlobData.fileName !== undefined) ? fileOrBlobData.fileName : fileOrBlobData.name;
                }
            }
            else {
                name = fileOrBlobData.name;
            }

            return name;
        },

        _parseFileOrBlobDataSize: function(fileOrBlobData) {
            var size;

            if (qq.isFileOrInput(fileOrBlobData)) {
                if (fileOrBlobData.value === undefined) {
                    // fix missing properties in Safari 4 and firefox 11.0a2
                    size = (fileOrBlobData.fileSize !== null && fileOrBlobData.fileSize !== undefined) ? fileOrBlobData.fileSize : fileOrBlobData.size;
                }
            }
            else {
                size = fileOrBlobData.blob.size;
            }

            return size;
        },

        _getValidationDescriptor: function(fileOrBlobData) {
            var fileDescriptor = {},
                name = this._parseFileOrBlobDataName(fileOrBlobData),
                size = this._parseFileOrBlobDataSize(fileOrBlobData);

            fileDescriptor.name = name;
            if (size !== undefined) {
                fileDescriptor.size = size;
            }

            return fileDescriptor;
        },

        _getValidationDescriptors: function(fileWrappers) {
            var self = this,
                fileDescriptors = [];

            qq.each(fileWrappers, function(idx, fileWrapper) {
                fileDescriptors.push(self._getValidationDescriptor(fileWrapper.file));
            });

            return fileDescriptors;
        },

        _createParamsStore: function(type) {
            var paramsStore = {},
                self = this;

            return {
                setParams: function(params, id) {
                    var paramsCopy = {};
                    qq.extend(paramsCopy, params);
                    paramsStore[id] = paramsCopy;
                },

                getParams: function(id) {
                    /*jshint eqeqeq: true, eqnull: true*/
                    var paramsCopy = {};

                    if (id != null && paramsStore[id]) {
                        qq.extend(paramsCopy, paramsStore[id]);
                    }
                    else {
                        qq.extend(paramsCopy, self._options[type].params);
                    }

                    return paramsCopy;
                },

                remove: function(fileId) {
                    return delete paramsStore[fileId];
                },

                reset: function() {
                    paramsStore = {};
                }
            };
        },

        _createEndpointStore: function(type) {
            var endpointStore = {},
            self = this;

            return {
                setEndpoint: function(endpoint, id) {
                    endpointStore[id] = endpoint;
                },

                getEndpoint: function(id) {
                    /*jshint eqeqeq: true, eqnull: true*/
                    if (id != null && endpointStore[id]) {
                        return endpointStore[id];
                    }

                    return self._options[type].endpoint;
                },

                remove: function(fileId) {
                    return delete endpointStore[fileId];
                },

                reset: function() {
                    endpointStore = {};
                }
            };
        },

        // Allows camera access on either the default or an extra button for iOS devices.
        _handleCameraAccess: function() {
            if (this._options.camera.ios && qq.ios()) {
                var acceptIosCamera = "image/*;capture=camera",
                    button = this._options.camera.button,
                    buttonId = button ? this._getButtonId(button) : this._defaultButtonId,
                    optionRoot = this._options;

                // If we are not targeting the default button, it is an "extra" button
                if (buttonId && buttonId !== this._defaultButtonId) {
                    optionRoot = this._extraButtonSpecs[buttonId];
                }

                // Camera access won't work in iOS if the `multiple` attribute is present on the file input
                optionRoot.multiple = false;

                // update the options
                if (optionRoot.validation.acceptFiles === null) {
                    optionRoot.validation.acceptFiles = acceptIosCamera;
                }
                else {
                    optionRoot.validation.acceptFiles += "," + acceptIosCamera;
                }

                // update the already-created button
                qq.each(this._buttons, function(idx, button) {
                    if (button.getButtonId() === buttonId) {
                        button.setMultiple(optionRoot.multiple);
                        button.setAcceptFiles(optionRoot.acceptFiles);

                        return false;
                    }
                });
            }
        },

        // Get the validation options for this button.  Could be the default validation option
        // or a specific one assigned to this particular button.
        _getValidationBase: function(buttonId) {
            var extraButtonSpec = this._extraButtonSpecs[buttonId];

            return extraButtonSpec ? extraButtonSpec.validation : this._options.validation;

        }
    };
}());

/*globals qq*/
(function(){
    "use strict";

    qq.FineUploaderBasic = function(o) {
        // These options define FineUploaderBasic mode.
        this._options = {
            debug: false,
            button: null,
            multiple: true,
            maxConnections: 3,
            disableCancelForFormUploads: false,
            autoUpload: true,

            request: {
                endpoint: "/server/upload",
                params: {},
                paramsInBody: true,
                customHeaders: {},
                forceMultipart: true,
                inputName: "qqfile",
                uuidName: "qquuid",
                totalFileSizeName: "qqtotalfilesize",
                filenameParam: "qqfilename"
            },

            validation: {
                allowedExtensions: [],
                sizeLimit: 0,
                minSizeLimit: 0,
                itemLimit: 0,
                stopOnFirstInvalidFile: true,
                acceptFiles: null,
                image: {
                    maxHeight: 0,
                    maxWidth: 0,
                    minHeight: 0,
                    minWidth: 0
                }
            },

            callbacks: {
                onSubmit: function(id, name){},
                onSubmitted: function(id, name){},
                onComplete: function(id, name, responseJSON, maybeXhr){},
                onCancel: function(id, name){},
                onUpload: function(id, name){},
                onUploadChunk: function(id, name, chunkData){},
                onUploadChunkSuccess: function(id, chunkData, responseJSON, xhr){},
                onResume: function(id, fileName, chunkData){},
                onProgress: function(id, name, loaded, total){},
                onError: function(id, name, reason, maybeXhrOrXdr) {},
                onAutoRetry: function(id, name, attemptNumber) {},
                onManualRetry: function(id, name) {},
                onValidateBatch: function(fileOrBlobData) {},
                onValidate: function(fileOrBlobData) {},
                onSubmitDelete: function(id) {},
                onDelete: function(id){},
                onDeleteComplete: function(id, xhrOrXdr, isError){},
                onPasteReceived: function(blob) {},
                onStatusChange: function(id, oldStatus, newStatus) {},
                onSessionRequestComplete: function(response, success, xhrOrXdr) {}
            },

            messages: {
                typeError: "{file} has an invalid extension. Valid extension(s): {extensions}.",
                sizeError: "{file} is too large, maximum file size is {sizeLimit}.",
                minSizeError: "{file} is too small, minimum file size is {minSizeLimit}.",
                emptyError: "{file} is empty, please select files again without it.",
                noFilesError: "No files to upload.",
                tooManyItemsError: "Too many items ({netItems}) would be uploaded.  Item limit is {itemLimit}.",
                maxHeightImageError: "Image is too tall.",
                maxWidthImageError: "Image is too wide.",
                minHeightImageError: "Image is not tall enough.",
                minWidthImageError: "Image is not wide enough.",
                retryFailTooManyItems: "Retry failed - you have reached your file limit.",
                onLeave: "The files are being uploaded, if you leave now the upload will be canceled."
            },

            retry: {
                enableAuto: false,
                maxAutoAttempts: 3,
                autoAttemptDelay: 5,
                preventRetryResponseProperty: "preventRetry"
            },

            classes: {
                buttonHover: "qq-upload-button-hover",
                buttonFocus: "qq-upload-button-focus"
            },

            chunking: {
                enabled: false,
                partSize: 2000000,
                paramNames: {
                    partIndex: "qqpartindex",
                    partByteOffset: "qqpartbyteoffset",
                    chunkSize: "qqchunksize",
                    totalFileSize: "qqtotalfilesize",
                    totalParts: "qqtotalparts"
                }
            },

            resume: {
                enabled: false,
                id: null,
                cookiesExpireIn: 7, //days
                paramNames: {
                    resuming: "qqresume"
                }
            },

            formatFileName: function(fileOrBlobName) {
                if (fileOrBlobName !== undefined && fileOrBlobName.length > 33) {
                    fileOrBlobName = fileOrBlobName.slice(0, 19) + "..." + fileOrBlobName.slice(-14);
                }
                return fileOrBlobName;
            },

            text: {
                defaultResponseError: "Upload failure reason unknown",
                sizeSymbols: ["kB", "MB", "GB", "TB", "PB", "EB"]
            },

            deleteFile : {
                enabled: false,
                method: "DELETE",
                endpoint: "/server/upload",
                customHeaders: {},
                params: {}
            },

            cors: {
                expected: false,
                sendCredentials: false,
                allowXdr: false
            },

            blobs: {
                defaultName: "misc_data"
            },

            paste: {
                targetElement: null,
                defaultName: "pasted_image"
            },

            camera: {
                ios: false,

                // if ios is true: button is null means target the default button, otherwise target the button specified
                button: null
            },

            // This refers to additional upload buttons to be handled by Fine Uploader.
            // Each element is an object, containing `element` as the only required
            // property.  The `element` must be a container that will ultimately
            // contain an invisible `<input type="file">` created by Fine Uploader.
            // Optional properties of each object include `multiple`, `validation`,
            // and `folders`.
            extraButtons: [],

            // Depends on the session module.  Used to query the server for an initial file list
            // during initialization and optionally after a `reset`.
            session: {
                endpoint: null,
                params: {},
                customHeaders: {},
                refreshOnReset: true
            }
        };

        // Replace any default options with user defined ones
        qq.extend(this._options, o, true);

        this._buttons = [];
        this._extraButtonSpecs = {};
        this._buttonIdsForFileIds = [];

        this._wrapCallbacks();
        this._disposeSupport =  new qq.DisposeSupport();

        this._storedIds = [];
        this._autoRetries = [];
        this._retryTimeouts = [];
        this._preventRetries = [];
        this._thumbnailUrls = [];

        this._netUploadedOrQueued = 0;
        this._netUploaded = 0;
        this._uploadData = this._createUploadDataTracker();

        this._paramsStore = this._createParamsStore("request");
        this._deleteFileParamsStore = this._createParamsStore("deleteFile");

        this._endpointStore = this._createEndpointStore("request");
        this._deleteFileEndpointStore = this._createEndpointStore("deleteFile");

        this._handler = this._createUploadHandler();

        this._deleteHandler = qq.DeleteFileAjaxRequester && this._createDeleteHandler();

        if (this._options.button) {
            this._defaultButtonId = this._createUploadButton({element: this._options.button}).getButtonId();
        }

        this._generateExtraButtonSpecs();

        this._handleCameraAccess();

        if (this._options.paste.targetElement) {
            if (qq.PasteSupport) {
                this._pasteHandler = this._createPasteHandler();
            }
            else {
                qq.log("Paste support module not found", "info");
            }
        }

        this._preventLeaveInProgress();

        this._imageGenerator = qq.ImageGenerator && new qq.ImageGenerator(qq.bind(this.log, this));
        this._refreshSessionData();
    };

    // Define the private & public API methods.
    qq.FineUploaderBasic.prototype = qq.basePublicApi;
    qq.extend(qq.FineUploaderBasic.prototype, qq.basePrivateApi);
}());

/*globals qq, XDomainRequest*/
/** Generic class for sending non-upload ajax requests and handling the associated responses **/
qq.AjaxRequester = function (o) {
    "use strict";

    var log, shouldParamsBeInQueryString,
        queue = [],
        requestData = [],
        options = {
            validMethods: ["POST"],
            method: "POST",
            contentType: "application/x-www-form-urlencoded",
            maxConnections: 3,
            customHeaders: {},
            endpointStore: {},
            paramsStore: {},
            mandatedParams: {},
            allowXRequestedWithAndCacheControl: true,
            successfulResponseCodes: {
                "DELETE": [200, 202, 204],
                "POST": [200, 204],
                "GET": [200]
            },
            cors: {
                expected: false,
                sendCredentials: false
            },
            log: function (str, level) {},
            onSend: function (id) {},
            onComplete: function (id, xhrOrXdr, isError) {}
        };

    qq.extend(options, o);
    log = options.log;

    if (qq.indexOf(options.validMethods, options.method) < 0) {
        throw new Error("'" + options.method + "' is not a supported method for this type of request!");
    }

    // [Simple methods](http://www.w3.org/TR/cors/#simple-method)
    // are defined by the W3C in the CORS spec as a list of methods that, in part,
    // make a CORS request eligible to be exempt from preflighting.
    function isSimpleMethod() {
        return qq.indexOf(["GET", "POST", "HEAD"], options.method) >= 0;
    }

    // [Simple headers](http://www.w3.org/TR/cors/#simple-header)
    // are defined by the W3C in the CORS spec as a list of headers that, in part,
    // make a CORS request eligible to be exempt from preflighting.
    function containsNonSimpleHeaders(headers) {
        var containsNonSimple = false;

        qq.each(containsNonSimple, function(idx, header) {
            if (qq.indexOf(["Accept", "Accept-Language", "Content-Language", "Content-Type"], header) < 0) {
                containsNonSimple = true;
                return false;
            }
        });

        return containsNonSimple;
    }

    function isXdr(xhr) {
        //The `withCredentials` test is a commonly accepted way to determine if XHR supports CORS.
        return options.cors.expected && xhr.withCredentials === undefined;
    }

    // Returns either a new `XMLHttpRequest` or `XDomainRequest` instance.
    function getCorsAjaxTransport() {
        var xhrOrXdr;

        if (window.XMLHttpRequest || window.ActiveXObject) {
            xhrOrXdr = qq.createXhrInstance();

            if (xhrOrXdr.withCredentials === undefined) {
                xhrOrXdr = new XDomainRequest();
            }
        }

        return xhrOrXdr;
    }

    // Returns either a new XHR/XDR instance, or an existing one for the associated `File` or `Blob`.
    function getXhrOrXdr(id, dontCreateIfNotExist) {
        var xhrOrXdr = requestData[id].xhr;

        if (!xhrOrXdr && !dontCreateIfNotExist) {
            if (options.cors.expected) {
                xhrOrXdr = getCorsAjaxTransport();
            }
            else {
                xhrOrXdr = qq.createXhrInstance();
            }

            requestData[id].xhr = xhrOrXdr;
        }

        return xhrOrXdr;
    }

    // Removes element from queue, sends next request
    function dequeue(id) {
        var i = qq.indexOf(queue, id),
            max = options.maxConnections,
            nextId;

        delete requestData[id];
        queue.splice(i, 1);

        if (queue.length >= max && i < max) {
            nextId = queue[max - 1];
            sendRequest(nextId);
        }
    }

    function onComplete(id, xdrError) {
        var xhr = getXhrOrXdr(id),
            method = options.method,
            isError = xdrError === true;

        dequeue(id);

        if (isError) {
            log(method + " request for " + id + " has failed", "error");
        }
        else if (!isXdr(xhr) && !isResponseSuccessful(xhr.status)) {
            isError = true;
            log(method + " request for " + id + " has failed - response code " + xhr.status, "error");
        }

        options.onComplete(id, xhr, isError);
    }

    function getParams(id) {
        var onDemandParams = requestData[id].additionalParams,
            mandatedParams = options.mandatedParams,
            params;

        if (options.paramsStore.getParams) {
            params = options.paramsStore.getParams(id);
        }

        if (onDemandParams) {
            qq.each(onDemandParams, function (name, val) {
                params = params || {};
                params[name] = val;
            });
        }

        if (mandatedParams) {
            qq.each(mandatedParams, function (name, val) {
                params = params || {};
                params[name] = val;
            });
        }

        return params;
    }

    function sendRequest(id) {
        var xhr = getXhrOrXdr(id),
            method = options.method,
            params = getParams(id),
            payload = requestData[id].payload,
            url;

        options.onSend(id);

        url = createUrl(id, params);

        // XDR and XHR status detection APIs differ a bit.
        if (isXdr(xhr)) {
            xhr.onload = getXdrLoadHandler(id);
            xhr.onerror = getXdrErrorHandler(id);
        }
        else {
            xhr.onreadystatechange = getXhrReadyStateChangeHandler(id);
        }

        // The last parameter is assumed to be ignored if we are actually using `XDomainRequest`.
        xhr.open(method, url, true);

        // Instruct the transport to send cookies along with the CORS request,
        // unless we are using `XDomainRequest`, which is not capable of this.
        if (options.cors.expected && options.cors.sendCredentials && !isXdr(xhr)) {
            xhr.withCredentials = true;
        }

        setHeaders(id);

        log("Sending " + method + " request for " + id);

        if (payload) {
            xhr.send(payload);
        }
        else if (shouldParamsBeInQueryString || !params) {
            xhr.send();
        }
        else if (params && options.contentType.toLowerCase().indexOf("application/x-www-form-urlencoded") >= 0) {
            xhr.send(qq.obj2url(params, ""));
        }
        else if (params && options.contentType.toLowerCase().indexOf("application/json") >= 0) {
            xhr.send(JSON.stringify(params));
        }
        else {
            xhr.send(params);
        }
    }

    function createUrl(id, params) {
        var endpoint = options.endpointStore.getEndpoint(id),
            addToPath = requestData[id].addToPath;

        /*jshint -W116,-W041 */
        if (addToPath != undefined) {
            endpoint += "/" + addToPath;
        }

        if (shouldParamsBeInQueryString && params) {
            return qq.obj2url(params, endpoint);
        }
        else {
            return endpoint;
        }
    }

    // Invoked by the UA to indicate a number of possible states that describe
    // a live `XMLHttpRequest` transport.
    function getXhrReadyStateChangeHandler(id) {
        return function () {
            if (getXhrOrXdr(id).readyState === 4) {
                onComplete(id);
            }
        };
    }

    // This will be called by IE to indicate **success** for an associated
    // `XDomainRequest` transported request.
    function getXdrLoadHandler(id) {
        return function () {
            onComplete(id);
        };
    }

    // This will be called by IE to indicate **failure** for an associated
    // `XDomainRequest` transported request.
    function getXdrErrorHandler(id) {
        return function () {
            onComplete(id, true);
        };
    }

    function setHeaders(id) {
        var xhr = getXhrOrXdr(id),
            customHeaders = options.customHeaders,
            onDemandHeaders = requestData[id].additionalHeaders || {},
            method = options.method,
            allHeaders = {};

        // If XDomainRequest is being used, we can't set headers, so just ignore this block.
        if (!isXdr(xhr)) {
            // Only attempt to add X-Requested-With & Cache-Control if permitted
            if (options.allowXRequestedWithAndCacheControl) {
                // Do not add X-Requested-With & Cache-Control if this is a cross-origin request
                // OR the cross-origin request contains a non-simple method or header.
                // This is done to ensure a preflight is not triggered exclusively based on the
                // addition of these 2 non-simple headers.
                if (!options.cors.expected || (!isSimpleMethod() || containsNonSimpleHeaders(customHeaders))) {
                    xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
                    xhr.setRequestHeader("Cache-Control", "no-cache");
                }
            }

            if (options.contentType && (method === "POST" || method === "PUT")) {
                xhr.setRequestHeader("Content-Type", options.contentType);
            }

            qq.extend(allHeaders, customHeaders);
            qq.extend(allHeaders, onDemandHeaders);

            qq.each(allHeaders, function (name, val) {
                xhr.setRequestHeader(name, val);
            });
        }
    }

    function isResponseSuccessful(responseCode) {
        return qq.indexOf(options.successfulResponseCodes[options.method], responseCode) >= 0;
    }

    function prepareToSend(id, addToPath, additionalParams, additionalHeaders, payload) {
        requestData[id] = {
            addToPath: addToPath,
            additionalParams: additionalParams,
            additionalHeaders: additionalHeaders,
            payload: payload
        };

        var len = queue.push(id);

        // if too many active connections, wait...
        if (len <= options.maxConnections) {
            sendRequest(id);
        }
    }


    shouldParamsBeInQueryString = options.method === "GET" || options.method === "DELETE";

    qq.extend(this, {
        // Start the process of sending the request.  The ID refers to the file associated with the request.
        initTransport: function(id) {
            var path, params, headers, payload;

            return {
                // Optionally specify the end of the endpoint path for the request.
                withPath: function(appendToPath) {
                    path = appendToPath;
                    return this;
                },

                // Optionally specify additional parameters to send along with the request.
                // These will be added to the query string for GET/DELETE requests or the payload
                // for POST/PUT requests.  The Content-Type of the request will be used to determine
                // how these parameters should be formatted as well.
                withParams: function(additionalParams) {
                    params = additionalParams;
                    return this;
                },

                // Optionally specify additional headers to send along with the request.
                withHeaders: function(additionalHeaders) {
                    headers = additionalHeaders;
                    return this;
                },

                // Optionally specify a payload/body for the request.
                withPayload: function(thePayload) {
                    payload = thePayload;
                    return this;
                },

                // Send the constructed request.
                send: function() {
                    prepareToSend(id, path, params, headers, payload);
                }
            };
        }
    });
};

/*globals qq*/
/**
 * Base upload handler module.  Delegates to more specific handlers.
 *
 * @param o Options.  Passed along to the specific handler submodule as well.
 * @param namespace [optional] Namespace for the specific handler.
 */
qq.UploadHandler = function(o, namespace) {
    "use strict";

    var queue = [],
        options, log, handlerImpl;

    // Default options, can be overridden by the user
    options = {
        debug: false,
        forceMultipart: true,
        paramsInBody: false,
        paramsStore: {},
        endpointStore: {},
        filenameParam: "qqfilename",
        cors: {
            expected: false,
            sendCredentials: false
        },
        maxConnections: 3, // maximum number of concurrent uploads
        uuidName: "qquuid",
        totalFileSizeName: "qqtotalfilesize",
        chunking: {
            enabled: false,
            partSize: 2000000, //bytes
            paramNames: {
                partIndex: "qqpartindex",
                partByteOffset: "qqpartbyteoffset",
                chunkSize: "qqchunksize",
                totalParts: "qqtotalparts",
                filename: "qqfilename"
            }
        },
        resume: {
            enabled: false,
            id: null,
            cookiesExpireIn: 7, //days
            paramNames: {
                resuming: "qqresume"
            }
        },
        log: function(str, level) {},
        onProgress: function(id, fileName, loaded, total){},
        onComplete: function(id, fileName, response, xhr){},
        onCancel: function(id, fileName){},
        onUpload: function(id, fileName){},
        onUploadChunk: function(id, fileName, chunkData){},
        onUploadChunkSuccess: function(id, chunkData, response, xhr){},
        onAutoRetry: function(id, fileName, response, xhr){},
        onResume: function(id, fileName, chunkData){},
        onUuidChanged: function(id, newUuid){},
        getName: function(id) {}

    };
    qq.extend(options, o);

    log = options.log;

    /**
     * Removes element from queue, starts upload of next
     */
    function dequeue(id) {
        var i = qq.indexOf(queue, id),
            max = options.maxConnections,
            nextId;

        if (i >= 0) {
            queue.splice(i, 1);

            if (queue.length >= max && i < max){
                nextId = queue[max-1];
                handlerImpl.upload(nextId);
            }
        }
    }

    function cancelSuccess(id) {
        log("Cancelling " + id);
        options.paramsStore.remove(id);
        dequeue(id);
    }

    function determineHandlerImpl() {
        var handlerType = namespace ? qq[namespace] : qq,
            handlerModuleSubtype = qq.supportedFeatures.ajaxUploading ? "Xhr" : "Form";

        handlerImpl = new handlerType["UploadHandler" + handlerModuleSubtype](
            options,
            {onUploadComplete: dequeue, onUuidChanged: options.onUuidChanged,
                getName: options.getName, getUuid: options.getUuid, getSize: options.getSize, log: log}
        );
    }


    qq.extend(this, {
        /**
         * Adds file or file input to the queue
         * @returns id
         **/
        add: function(id, file) {
            return handlerImpl.add.apply(this, arguments);
        },

        /**
         * Sends the file identified by id
         */
        upload: function(id) {
            var len = queue.push(id);

            // if too many active uploads, wait...
            if (len <= options.maxConnections){
                handlerImpl.upload(id);
                return true;
            }

            return false;
        },

        retry: function(id) {
            var i = qq.indexOf(queue, id);
            if (i >= 0) {
                return handlerImpl.upload(id, true);
            }
            else {
                return this.upload(id);
            }
        },

        /**
         * Cancels file upload by id
         */
        cancel: function(id) {
            var cancelRetVal = handlerImpl.cancel(id);

            if (cancelRetVal instanceof qq.Promise) {
                cancelRetVal.then(function() {
                    cancelSuccess(id);
                });
            }
            else if (cancelRetVal !== false) {
                cancelSuccess(id);
            }
        },

        /**
         * Cancels all queued or in-progress uploads
         */
        cancelAll: function() {
            var self = this,
                queueCopy = [];

            qq.extend(queueCopy, queue);
            qq.each(queueCopy, function(idx, fileId) {
                self.cancel(fileId);
            });

            queue = [];
        },

        getFile: function(id) {
            if (handlerImpl.getFile) {
                return handlerImpl.getFile(id);
            }
        },

        getInput: function(id) {
            if (handlerImpl.getInput) {
                return handlerImpl.getInput(id);
            }
        },

        reset: function() {
            log("Resetting upload handler");
            this.cancelAll();
            queue = [];
            handlerImpl.reset();
        },

        expunge: function(id) {
            if (this.isValid(id)) {
                return handlerImpl.expunge(id);
            }
        },

        /**
         * Determine if the file exists.
         */
        isValid: function(id) {
            return handlerImpl.isValid(id);
        },

        getResumableFilesData: function() {
            if (handlerImpl.getResumableFilesData) {
                return handlerImpl.getResumableFilesData();
            }
            return [];
        },

        /**
         * This may or may not be implemented, depending on the handler.  For handlers where a third-party ID is
         * available (such as the "key" for Amazon S3), this will return that value.  Otherwise, the return value
         * will be undefined.
         *
         * @param id Internal file ID
         * @returns {*} Some identifier used by a 3rd-party service involved in the upload process
         */
        getThirdPartyFileId: function(id) {
            if (handlerImpl.getThirdPartyFileId && this.isValid(id)) {
                return handlerImpl.getThirdPartyFileId(id);
            }
        },

        /**
         * Attempts to pause the associated upload if the specific handler supports this and the file is "valid".
         * @param id ID of the upload/file to pause
         * @returns {boolean} true if the upload was paused
         */
        pause: function(id) {
            if (handlerImpl.pause && this.isValid(id) && handlerImpl.pause(id)) {
                dequeue(id);
                return true;
            }
        }
    });

    determineHandlerImpl();
};

/* globals qq */
/**
 * Common APIs exposed to creators of upload via form/iframe handlers.  This is reused and possibly overridden
 * in some cases by specific form upload handlers.
 *
 * @param internalApi Object that will be filled with internal API methods
 * @param spec Options/static values used to configure this handler
 * @param proxy Callbacks & methods used to query for or push out data/changes
 * @constructor
 */
qq.UploadHandlerFormApi = function(internalApi, spec, proxy) {
    "use strict";

    var formHandlerInstanceId = qq.getUniqueId(),
        onloadCallbacks = {},
        detachLoadEvents = {},
        postMessageCallbackTimers = {},
        publicApi = this,
        isCors = spec.isCors,
        fileState = spec.fileState,
        inputName = spec.inputName,
        onCancel = proxy.onCancel,
        onUuidChanged = proxy.onUuidChanged,
        getName = proxy.getName,
        getUuid = proxy.getUuid,
        log = proxy.log,
        corsMessageReceiver = new qq.WindowReceiveMessage({log: log});


    /**
     * Remove any trace of the file from the handler.
     *
     * @param id ID of the associated file
     */
    function expungeFile(id) {
        delete detachLoadEvents[id];
        delete fileState[id];

        // If we are dealing with CORS, we might still be waiting for a response from a loaded iframe.
        // In that case, terminate the timer waiting for a message from the loaded iframe
        // and stop listening for any more messages coming from this iframe.
        if (isCors) {
            clearTimeout(postMessageCallbackTimers[id]);
            delete postMessageCallbackTimers[id];
            corsMessageReceiver.stopReceivingMessages(id);
        }

        var iframe = document.getElementById(internalApi.getIframeName(id));
        if (iframe) {
            // To cancel request set src to something else.  We use src="javascript:false;"
            // because it doesn't trigger ie6 prompt on https
            iframe.setAttribute("src", "java" + String.fromCharCode(115) + "cript:false;"); //deal with "JSLint: javascript URL" warning, which apparently cannot be turned off

            qq(iframe).remove();
        }
    }

    /**
     * If we are in CORS mode, we must listen for messages (containing the server response) from the associated
     * iframe, since we cannot directly parse the content of the iframe due to cross-origin restrictions.
     *
     * @param iframe Listen for messages on this iframe.
     * @param callback Invoke this callback with the message from the iframe.
     */
    function registerPostMessageCallback(iframe, callback) {
        var iframeName = iframe.id,
            fileId = getFileIdForIframeName(iframeName),
            uuid = getUuid(fileId);

        onloadCallbacks[uuid] = callback;

        // When the iframe has loaded (after the server responds to an upload request)
        // declare the attempt a failure if we don't receive a valid message shortly after the response comes in.
        detachLoadEvents[fileId] = qq(iframe).attach("load", function() {
            if (fileState[fileId].input) {
                log("Received iframe load event for CORS upload request (iframe name " + iframeName + ")");

                postMessageCallbackTimers[iframeName] = setTimeout(function() {
                    var errorMessage = "No valid message received from loaded iframe for iframe name " + iframeName;
                    log(errorMessage, "error");
                    callback({
                        error: errorMessage
                    });
                }, 1000);
            }
        });

        // Listen for messages coming from this iframe.  When a message has been received, cancel the timer
        // that declares the upload a failure if a message is not received within a reasonable amount of time.
        corsMessageReceiver.receiveMessage(iframeName, function(message) {
            log("Received the following window message: '" + message + "'");
            var fileId = getFileIdForIframeName(iframeName),
                response = internalApi.parseJsonResponse(fileId, message),
                uuid = response.uuid,
                onloadCallback;

            if (uuid && onloadCallbacks[uuid]) {
                log("Handling response for iframe name " + iframeName);
                clearTimeout(postMessageCallbackTimers[iframeName]);
                delete postMessageCallbackTimers[iframeName];

                internalApi.detachLoadEvent(iframeName);

                onloadCallback = onloadCallbacks[uuid];

                delete onloadCallbacks[uuid];
                corsMessageReceiver.stopReceivingMessages(iframeName);
                onloadCallback(response);
            }
            else if (!uuid) {
                log("'" + message + "' does not contain a UUID - ignoring.");
            }
        });
    }

    /**
     * Generates an iframe to be used as a target for upload-related form submits.  This also adds the iframe
     * to the current `document`.  Note that the iframe is hidden from view.
     *
     * @param name Name of the iframe.
     * @returns {HTMLIFrameElement} The created iframe
     */
    function initIframeForUpload(name) {
        var iframe = qq.toElement("<iframe src='javascript:false;' name='" + name + "' />");

        iframe.setAttribute("id", name);

        iframe.style.display = "none";
        document.body.appendChild(iframe);

        return iframe;
    }

    /**
     * @param iframeName `document`-unique Name of the associated iframe
     * @returns {*} ID of the associated file
     */
    function getFileIdForIframeName(iframeName) {
        return iframeName.split("_")[0];
    }


// INTERNAL API

    qq.extend(internalApi, {
        /**
         * @param fileId ID of the associated file
         * @returns {string} The `document`-unique name of the iframe
         */
        getIframeName: function(fileId) {
            return fileId + "_" + formHandlerInstanceId;
        },

        /**
         * Creates an iframe with a specific document-unique name.
         *
         * @param id ID of the associated file
         * @returns {HTMLIFrameElement}
         */
        createIframe: function(id) {
            var iframeName = internalApi.getIframeName(id);

            return initIframeForUpload(iframeName);
        },

        /**
         * @param id ID of the associated file
         * @param innerHtmlOrMessage JSON message
         * @returns {*} The parsed response, or an empty object if the response could not be parsed
         */
        parseJsonResponse: function(id, innerHtmlOrMessage) {
            var response;

            try {
                response = qq.parseJson(innerHtmlOrMessage);

                if (response.newUuid !== undefined) {
                    onUuidChanged(id, response.newUuid);
                }
            }
            catch(error) {
                log("Error when attempting to parse iframe upload response (" + error.message + ")", "error");
                response = {};
            }

            return response;
        },

        /**
         * Generates a form element and appends it to the `document`.  When the form is submitted, a specific iframe is targeted.
         * The name of the iframe is passed in as a property of the spec parameter, and must be unique in the `document`.  Note
         * that the form is hidden from view.
         *
         * @param spec An object containing various properties to be used when constructing the form.  Required properties are
         * currently: `method`, `endpoint`, `params`, `paramsInBody`, and `targetName`.
         * @returns {HTMLFormElement} The created form
         */
        initFormForUpload: function(spec) {
            var method = spec.method,
                endpoint = spec.endpoint,
                params = spec.params,
                paramsInBody = spec.paramsInBody,
                targetName = spec.targetName,
                form = qq.toElement("<form method='" + method + "' enctype='multipart/form-data'></form>"),
                url = endpoint;

            if (paramsInBody) {
                qq.obj2Inputs(params, form);
            }
            else {
                url = qq.obj2url(params, endpoint);
            }

            form.setAttribute("action", url);
            form.setAttribute("target", targetName);
            form.style.display = "none";
            document.body.appendChild(form);

            return form;
        },

        /**
         * This function either delegates to a more specific message handler if CORS is involved,
         * or simply registers a callback when the iframe has been loaded that invokes the passed callback
         * after determining if the content of the iframe is accessible.
         *
         * @param iframe Associated iframe
         * @param callback Callback to invoke after we have determined if the iframe content is accessible.
         */
        attachLoadEvent: function(iframe, callback) {
            /*jslint eqeq: true*/
            var responseDescriptor;

            if (isCors) {
                registerPostMessageCallback(iframe, callback);
            }
            else {
                detachLoadEvents[iframe.id] = qq(iframe).attach("load", function(){
                    log("Received response for " + iframe.id);

                    // when we remove iframe from dom
                    // the request stops, but in IE load
                    // event fires
                    if (!iframe.parentNode){
                        return;
                    }

                    try {
                        // fixing Opera 10.53
                        if (iframe.contentDocument &&
                            iframe.contentDocument.body &&
                            iframe.contentDocument.body.innerHTML == "false"){
                            // In Opera event is fired second time
                            // when body.innerHTML changed from false
                            // to server response approx. after 1 sec
                            // when we upload file with iframe
                            return;
                        }
                    }
                    catch (error) {
                        //IE may throw an "access is denied" error when attempting to access contentDocument on the iframe in some cases
                        log("Error when attempting to access iframe during handling of upload response (" + error.message + ")", "error");
                        responseDescriptor = {success: false};
                    }

                    callback(responseDescriptor);
                });
            }
        },

        /**
         * Called when we are no longer interested in being notified when an iframe has loaded.
         *
         * @param id Associated file ID
         */
        detachLoadEvent: function(id) {
            if (detachLoadEvents[id] !== undefined) {
                detachLoadEvents[id]();
                delete detachLoadEvents[id];
            }
        }
    });


// PUBLIC API

    qq.extend(this, {
        add: function(id, fileInput) {
            fileState[id] = {input: fileInput};

            fileInput.setAttribute("name", inputName);

            // remove file input from DOM
            if (fileInput.parentNode){
                qq(fileInput).remove();
            }
        },

        getInput: function(id) {
            return fileState[id].input;
        },

        isValid: function(id) {
            return fileState[id] !== undefined &&
                fileState[id].input !== undefined;
        },

        reset: function() {
            fileState.length = 0;
        },

        expunge: function(id) {
            return expungeFile(id);
        },

        cancel: function(id) {
            var onCancelRetVal = onCancel(id, getName(id));

            if (onCancelRetVal instanceof qq.Promise) {
                return onCancelRetVal.then(function() {
                    this.expunge(id);
                });
            }
            else if (onCancelRetVal !== false) {
                this.expunge(id);
                return true;
            }

            return false;
        },

        upload: function(id) {
            // implementation-specific
        }
    });
};

/* globals qq */
/**
 * Common API exposed to creators of XHR handlers.  This is reused and possibly overriding in some cases by specific
 * XHR upload handlers.
 *
 * @param internalApi Object that will be filled with internal API methods
 * @param spec Options/static values used to configure this handler
 * @param proxy Callbacks & methods used to query for or push out data/changes
 * @constructor
 */
qq.UploadHandlerXhrApi = function(internalApi, spec, proxy) {
    "use strict";

    var publicApi = this,
        fileState = spec.fileState,
        chunking = spec.chunking,
        onUpload = proxy.onUpload,
        onCancel = proxy.onCancel,
        onUuidChanged = proxy.onUuidChanged,
        getName = proxy.getName,
        getSize = proxy.getSize,
        log = proxy.log;


    function getChunk(fileOrBlob, startByte, endByte) {
        if (fileOrBlob.slice) {
            return fileOrBlob.slice(startByte, endByte);
        }
        else if (fileOrBlob.mozSlice) {
            return fileOrBlob.mozSlice(startByte, endByte);
        }
        else if (fileOrBlob.webkitSlice) {
            return fileOrBlob.webkitSlice(startByte, endByte);
        }
    }

    qq.extend(internalApi, {
        /**
         * Creates an XHR instance for this file and stores it in the fileState.
         *
         * @param id File ID
         * @returns {XMLHttpRequest}
         */
        createXhr: function(id) {
            var xhr = qq.createXhrInstance();

            fileState[id].xhr = xhr;

            return xhr;
        },

        /**
         * @param id ID of the associated file
         * @returns {number} Number of parts this file can be divided into, or undefined if chunking is not supported in this UA
         */
        getTotalChunks: function(id) {
            if (chunking) {
                var fileSize = getSize(id),
                    chunkSize = chunking.partSize;

                return Math.ceil(fileSize / chunkSize);
            }
        },

        getChunkData: function(id, chunkIndex) {
            var chunkSize = chunking.partSize,
                fileSize = getSize(id),
                fileOrBlob = publicApi.getFile(id),
                startBytes = chunkSize * chunkIndex,
                endBytes = startBytes+chunkSize >= fileSize ? fileSize : startBytes+chunkSize,
                totalChunks = internalApi.getTotalChunks(id);

            return {
                part: chunkIndex,
                start: startBytes,
                end: endBytes,
                count: totalChunks,
                blob: getChunk(fileOrBlob, startBytes, endBytes),
                size: endBytes - startBytes
            };
        },

        getChunkDataForCallback: function(chunkData) {
            return {
                partIndex: chunkData.part,
                startByte: chunkData.start + 1,
                endByte: chunkData.end,
                totalParts: chunkData.count
            };
        }
    });

    qq.extend(this, {
        /**
         * Adds File or Blob to the queue
         **/
        add: function(id, fileOrBlobData) {
            if (qq.isFile(fileOrBlobData)) {
                fileState[id] = {file: fileOrBlobData};
            }
            else if (qq.isBlob(fileOrBlobData.blob)) {
                fileState[id] =  {blobData: fileOrBlobData};
            }
            else {
                throw new Error("Passed obj is not a File or BlobData (in qq.UploadHandlerXhr)");
            }
        },

        getFile: function(id) {
            if (fileState[id]) {
                return fileState[id].file || fileState[id].blobData.blob;
            }
        },

        isValid: function(id) {
            return fileState[id] !== undefined;
        },

        reset: function() {
            fileState.length = 0;
        },

        expunge: function(id) {
            var xhr = fileState[id].xhr;

            if (xhr) {
                xhr.onreadystatechange = null;
                xhr.abort();
            }

            delete fileState[id];
        },

        /**
         * Sends the file identified by id to the server
         */
        upload: function(id, retry) {
            fileState[id] && delete fileState[id].paused;
            return onUpload(id, retry);
        },

        cancel: function(id) {
            var onCancelRetVal = onCancel(id, getName(id));

            if (onCancelRetVal instanceof qq.Promise) {
                return onCancelRetVal.then(function() {
                    this.expunge(id);
                });
            }
            else if (onCancelRetVal !== false) {
                this.expunge(id);
                return true;
            }

            return false;
        },

        pause: function(id) {
            var xhr = fileState[id].xhr;

            if(xhr) {
                log(qq.format("Aborting XHR upload for {} '{}' due to pause instruction.", id, getName(id)));
                fileState[id].paused = true;
                xhr.abort();
                return true;
            }
        }
    });
};

/*globals qq */
/*jshint -W117 */
qq.WindowReceiveMessage = function(o) {
    "use strict";

    var options = {
            log: function(message, level) {}
        },
        callbackWrapperDetachers = {};

    qq.extend(options, o);

    qq.extend(this, {
        receiveMessage : function(id, callback) {
            var onMessageCallbackWrapper = function(event) {
                    callback(event.data);
                };

            if (window.postMessage) {
                callbackWrapperDetachers[id] = qq(window).attach("message", onMessageCallbackWrapper);
            }
            else {
                log("iframe message passing not supported in this browser!", "error");
            }
        },

        stopReceivingMessages : function(id) {
            if (window.postMessage) {
                var detacher = callbackWrapperDetachers[id];
                if (detacher) {
                    detacher();
                }
            }
        }
    });
};

/*globals qq*/
/**
 * Upload handler used that assumes the current user agent does not have any support for the
 * File API, and, therefore, makes use of iframes and forms to submit the files directly to
 * a generic server.
 *
 * @param options Options passed from the base handler
 * @param proxy Callbacks & methods used to query for or push out data/changes
 */
qq.UploadHandlerForm = function(options, proxy) {
    "use strict";

    var fileState = [],
        uploadCompleteCallback = proxy.onUploadComplete,
        onUuidChanged = proxy.onUuidChanged,
        getName = proxy.getName,
        getUuid = proxy.getUuid,
        uploadComplete = uploadCompleteCallback,
        log = proxy.log,
        internalApi = {};


    /**
     * Returns json object received by iframe from server.
     */
    function getIframeContentJson(id, iframe) {
        /*jshint evil: true*/

        var response;

        //IE may throw an "access is denied" error when attempting to access contentDocument on the iframe in some cases
        try {
            // iframe.contentWindow.document - for IE<7
            var doc = iframe.contentDocument || iframe.contentWindow.document,
                innerHtml = doc.body.innerHTML;

            log("converting iframe's innerHTML to JSON");
            log("innerHTML = " + innerHtml);
            //plain text response may be wrapped in <pre> tag
            if (innerHtml && innerHtml.match(/^<pre/i)) {
                innerHtml = doc.body.firstChild.firstChild.nodeValue;
            }

            response = internalApi.parseJsonResponse(id, innerHtml);
        }
        catch(error) {
            log("Error when attempting to parse form upload response (" + error.message + ")", "error");
            response = {success: false};
        }

        return response;
    }

    /**
     * Creates form, that will be submitted to iframe
     */
    function createForm(id, iframe){
        var params = options.paramsStore.getParams(id),
            method = options.demoMode ? "GET" : "POST",
            endpoint = options.endpointStore.getEndpoint(id),
            name = getName(id);

        params[options.uuidName] = getUuid(id);
        params[options.filenameParam] = name;

        return internalApi.initFormForUpload({
            method: method,
            endpoint: endpoint,
            params: params,
            paramsInBody: options.paramsInBody,
            targetName: iframe.name
        });
    }

    qq.extend(this, new qq.UploadHandlerFormApi(internalApi,
        {fileState: fileState, isCors: options.cors.expected, inputName: options.inputName},
        {onCancel: options.onCancel, onUuidChanged: onUuidChanged, getName: getName, getUuid: getUuid, log: log}));

    qq.extend(this, {
        upload: function(id) {
            var input = fileState[id].input,
                fileName = getName(id),
                iframe = internalApi.createIframe(id),
                form;

            if (!input){
                throw new Error("file with passed id was not added, or already uploaded or canceled");
            }

            options.onUpload(id, getName(id));

            form = createForm(id, iframe);
            form.appendChild(input);

            internalApi.attachLoadEvent(iframe, function(responseFromMessage){
                log("iframe loaded");

                var response = responseFromMessage ? responseFromMessage : getIframeContentJson(id, iframe);

                internalApi.detachLoadEvent(id);

                //we can't remove an iframe if the iframe doesn't belong to the same domain
                if (!options.cors.expected) {
                    qq(iframe).remove();
                }

                if (!response.success) {
                    if (options.onAutoRetry(id, fileName, response)) {
                        return;
                    }
                }
                options.onComplete(id, fileName, response);
                uploadComplete(id);
            });

            log("Sending upload request for " + id);
            form.submit();
            qq(form).remove();
        }
    });
};

/*globals qq*/
/**
 * Upload handler used to upload to traditional endpoints.  It depends on File API support, and, therefore,
 * makes use of `XMLHttpRequest` level 2 to upload `File`s and `Blob`s to a generic server.
 *
 * @param spec Options passed from the base handler
 * @param proxy Callbacks & methods used to query for or push out data/changes
 */
qq.UploadHandlerXhr = function(spec, proxy) {
    "use strict";

    var uploadComplete = proxy.onUploadComplete,
        onUuidChanged = proxy.onUuidChanged,
        getName = proxy.getName,
        getUuid = proxy.getUuid,
        getSize = proxy.getSize,
        log = proxy.log,
        fileState = [],
        cookieItemDelimiter = "|",
        chunkFiles = spec.chunking.enabled && qq.supportedFeatures.chunking,
        resumeEnabled = spec.resume.enabled && chunkFiles && qq.supportedFeatures.resume,
        multipart = spec.forceMultipart || spec.paramsInBody,
        internalApi = {},
        publicApi = this,
        resumeId;

    function getResumeId() {
        if (spec.resume.id !== null &&
            spec.resume.id !== undefined &&
            !qq.isFunction(spec.resume.id) &&
            !qq.isObject(spec.resume.id)) {

            return spec.resume.id;
        }
    }

    resumeId = getResumeId();

    function addChunkingSpecificParams(id, params, chunkData) {
        var size = getSize(id),
            name = getName(id);

        params[spec.chunking.paramNames.partIndex] = chunkData.part;
        params[spec.chunking.paramNames.partByteOffset] = chunkData.start;
        params[spec.chunking.paramNames.chunkSize] = chunkData.size;
        params[spec.chunking.paramNames.totalParts] = chunkData.count;
        params[spec.totalFileSizeName] = size;

        /**
         * When a Blob is sent in a multipart request, the filename value in the content-disposition header is either "blob"
         * or an empty string.  So, we will need to include the actual file name as a param in this case.
         */
        if (multipart) {
            params[spec.filenameParam] = name;
        }
    }

    function addResumeSpecificParams(params) {
        params[spec.resume.paramNames.resuming] = true;
    }

    function getChunk(fileOrBlob, startByte, endByte) {
        if (fileOrBlob.slice) {
            return fileOrBlob.slice(startByte, endByte);
        }
        else if (fileOrBlob.mozSlice) {
            return fileOrBlob.mozSlice(startByte, endByte);
        }
        else if (fileOrBlob.webkitSlice) {
            return fileOrBlob.webkitSlice(startByte, endByte);
        }
    }

    function setParamsAndGetEntityToSend(params, xhr, fileOrBlob, id) {
        var formData = new FormData(),
            method = spec.demoMode ? "GET" : "POST",
            endpoint = spec.endpointStore.getEndpoint(id),
            url = endpoint,
            name = getName(id),
            size = getSize(id);

        params[spec.uuidName] = getUuid(id);
        params[spec.filenameParam] = name;


        if (multipart) {
            params[spec.totalFileSizeName] = size;
        }

        //build query string
        if (!spec.paramsInBody) {
            if (!multipart) {
                params[spec.inputName] = name;
            }
            url = qq.obj2url(params, endpoint);
        }

        xhr.open(method, url, true);

        if (spec.cors.expected && spec.cors.sendCredentials) {
            xhr.withCredentials = true;
        }

        if (multipart) {
            if (spec.paramsInBody) {
                qq.obj2FormData(params, formData);
            }

            formData.append(spec.inputName, fileOrBlob);
            return formData;
        }

        return fileOrBlob;
    }

    function setHeaders(id, xhr) {
        var extraHeaders = spec.customHeaders,
            fileOrBlob = fileState[id].file || fileState[id].blobData.blob;

        xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
        xhr.setRequestHeader("Cache-Control", "no-cache");

        if (!multipart) {
            xhr.setRequestHeader("Content-Type", "application/octet-stream");
            //NOTE: return mime type in xhr works on chrome 16.0.9 firefox 11.0a2
            xhr.setRequestHeader("X-Mime-Type", fileOrBlob.type);
        }

        qq.each(extraHeaders, function(name, val) {
            xhr.setRequestHeader(name, val);
        });
    }

    function handleCompletedItem(id, response, xhr) {
        var name = getName(id),
            size = getSize(id);

        fileState[id].attemptingResume = false;

        spec.onProgress(id, name, size, size);
        spec.onComplete(id, name, response, xhr);

        if (fileState[id]) {
            delete fileState[id].xhr;
        }

        uploadComplete(id);
    }

    function uploadNextChunk(id) {
        var chunkIdx = fileState[id].remainingChunkIdxs[0],
            chunkData = internalApi.getChunkData(id, chunkIdx),
            xhr = internalApi.createXhr(id),
            size = getSize(id),
            name = getName(id),
            toSend, params;

        if (fileState[id].loaded === undefined) {
            fileState[id].loaded = 0;
        }

        if (resumeEnabled && fileState[id].file) {
            persistChunkData(id, chunkData);
        }

        xhr.onreadystatechange = getReadyStateChangeHandler(id, xhr);

        xhr.upload.onprogress = function(e) {
            if (e.lengthComputable) {
                var totalLoaded = e.loaded + fileState[id].loaded,
                    estTotalRequestsSize = calcAllRequestsSizeForChunkedUpload(id, chunkIdx, e.total);

                spec.onProgress(id, name, totalLoaded, estTotalRequestsSize);
            }
        };

        spec.onUploadChunk(id, name, internalApi.getChunkDataForCallback(chunkData));

        params = spec.paramsStore.getParams(id);
        addChunkingSpecificParams(id, params, chunkData);

        if (fileState[id].attemptingResume) {
            addResumeSpecificParams(params);
        }

        toSend = setParamsAndGetEntityToSend(params, xhr, chunkData.blob, id);
        setHeaders(id, xhr);

        log("Sending chunked upload request for item " + id + ": bytes " + (chunkData.start+1) + "-" + chunkData.end + " of " + size);
        xhr.send(toSend);
    }

    function calcAllRequestsSizeForChunkedUpload(id, chunkIdx, requestSize) {
        var chunkData = internalApi.getChunkData(id, chunkIdx),
            blobSize = chunkData.size,
            overhead = requestSize - blobSize,
            size = getSize(id),
            chunkCount = chunkData.count,
            initialRequestOverhead = fileState[id].initialRequestOverhead,
            overheadDiff = overhead - initialRequestOverhead;

        fileState[id].lastRequestOverhead = overhead;

        if (chunkIdx === 0) {
            fileState[id].lastChunkIdxProgress = 0;
            fileState[id].initialRequestOverhead = overhead;
            fileState[id].estTotalRequestsSize = size + (chunkCount * overhead);
        }
        else if (fileState[id].lastChunkIdxProgress !== chunkIdx) {
            fileState[id].lastChunkIdxProgress = chunkIdx;
            fileState[id].estTotalRequestsSize += overheadDiff;
        }

        return fileState[id].estTotalRequestsSize;
    }

    function getLastRequestOverhead(id) {
        if (multipart) {
            return fileState[id].lastRequestOverhead;
        }
        else {
            return 0;
        }
    }

    function handleSuccessfullyCompletedChunk(id, response, xhr) {
        var chunkIdx = fileState[id].remainingChunkIdxs.shift(),
            chunkData = internalApi.getChunkData(id, chunkIdx);

        fileState[id].attemptingResume = false;
        fileState[id].loaded += chunkData.size + getLastRequestOverhead(id);

        spec.onUploadChunkSuccess(id, internalApi.getChunkDataForCallback(chunkData), response, xhr);

        if (fileState[id].remainingChunkIdxs.length > 0) {
            uploadNextChunk(id);
        }
        else {
            if (resumeEnabled) {
                deletePersistedChunkData(id);
            }

            handleCompletedItem(id, response, xhr);
        }
    }

    function isErrorResponse(xhr, response) {
        return xhr.status !== 200 || !response.success || response.reset;
    }

    function parseResponse(id, xhr) {
        var response;

        try {
            log(qq.format("Received response status {} with body: {}", xhr.status, xhr.responseText));

            response = qq.parseJson(xhr.responseText);

            if (response.newUuid !== undefined) {
                onUuidChanged(id, response.newUuid);
            }
        }
        catch(error) {
            log("Error when attempting to parse xhr response text (" + error.message + ")", "error");
            response = {};
        }

        return response;
    }

    function handleResetResponse(id) {
        log("Server has ordered chunking effort to be restarted on next attempt for item ID " + id, "error");

        if (resumeEnabled) {
            deletePersistedChunkData(id);
            fileState[id].attemptingResume = false;
        }

        fileState[id].remainingChunkIdxs = [];
        delete fileState[id].loaded;
        delete fileState[id].estTotalRequestsSize;
        delete fileState[id].initialRequestOverhead;
    }

    function handleResetResponseOnResumeAttempt(id) {
        fileState[id].attemptingResume = false;
        log("Server has declared that it cannot handle resume for item ID " + id + " - starting from the first chunk", "error");
        handleResetResponse(id);
        publicApi.upload(id, true);
    }

    function handleNonResetErrorResponse(id, response, xhr) {
        var name = getName(id);

        if (spec.onAutoRetry(id, name, response, xhr)) {
            return;
        }
        else {
            handleCompletedItem(id, response, xhr);
        }
    }

    function onComplete(id, xhr) {
        var state = fileState[id],
            attemptingResume = state && state.attemptingResume,
            paused = state && state.paused,
            response;

        // The logic in this function targets uploads that have not been paused or canceled,
        // so return at once if this is not the case.
        if (!state || paused) {
            return;
        }

        log("xhr - server response received for " + id);
        log("responseText = " + xhr.responseText);
        response = parseResponse(id, xhr);

        if (isErrorResponse(xhr, response)) {
            if (response.reset) {
                handleResetResponse(id);
            }

            if (attemptingResume && response.reset) {
                handleResetResponseOnResumeAttempt(id);
            }
            else {
                handleNonResetErrorResponse(id, response, xhr);
            }
        }
        else if (chunkFiles) {
            handleSuccessfullyCompletedChunk(id, response, xhr);
        }
        else {
            handleCompletedItem(id, response, xhr);
        }
    }

    function getReadyStateChangeHandler(id, xhr) {
        return function() {
            if (xhr.readyState === 4) {
                onComplete(id, xhr);
            }
        };
    }

    function persistChunkData(id, chunkData) {
        var fileUuid = getUuid(id),
            lastByteSent = fileState[id].loaded,
            initialRequestOverhead = fileState[id].initialRequestOverhead,
            estTotalRequestsSize = fileState[id].estTotalRequestsSize,
            cookieName = getChunkDataCookieName(id),
            cookieValue = fileUuid +
                cookieItemDelimiter + chunkData.part +
                cookieItemDelimiter + lastByteSent +
                cookieItemDelimiter + initialRequestOverhead +
                cookieItemDelimiter + estTotalRequestsSize,
            cookieExpDays = spec.resume.cookiesExpireIn;

        qq.setCookie(cookieName, cookieValue, cookieExpDays);
    }

    function deletePersistedChunkData(id) {
        if (fileState[id].file) {
            var cookieName = getChunkDataCookieName(id);
            qq.deleteCookie(cookieName);
        }
    }

    function getPersistedChunkData(id) {
        var chunkCookieValue = qq.getCookie(getChunkDataCookieName(id)),
            filename = getName(id),
            sections, uuid, partIndex, lastByteSent, initialRequestOverhead, estTotalRequestsSize;

        if (chunkCookieValue) {
            sections = chunkCookieValue.split(cookieItemDelimiter);

            if (sections.length === 5) {
                uuid = sections[0];
                partIndex = parseInt(sections[1], 10);
                lastByteSent = parseInt(sections[2], 10);
                initialRequestOverhead = parseInt(sections[3], 10);
                estTotalRequestsSize = parseInt(sections[4], 10);

                return {
                    uuid: uuid,
                    part: partIndex,
                    lastByteSent: lastByteSent,
                    initialRequestOverhead: initialRequestOverhead,
                    estTotalRequestsSize: estTotalRequestsSize
                };
            }
            else {
                log("Ignoring previously stored resume/chunk cookie for " + filename + " - old cookie format", "warn");
            }
        }
    }

    function getChunkDataCookieName(id) {
        var filename = getName(id),
            fileSize = getSize(id),
            maxChunkSize = spec.chunking.partSize,
            cookieName;

        cookieName = "qqfilechunk" + cookieItemDelimiter + encodeURIComponent(filename) + cookieItemDelimiter + fileSize + cookieItemDelimiter + maxChunkSize;

        if (resumeId !== undefined) {
            cookieName += cookieItemDelimiter + resumeId;
        }

        return cookieName;
    }

    function calculateRemainingChunkIdxsAndUpload(id, firstChunkIndex) {
        var currentChunkIndex;

        for (currentChunkIndex = internalApi.getTotalChunks(id)-1; currentChunkIndex >= firstChunkIndex; currentChunkIndex-=1) {
            fileState[id].remainingChunkIdxs.unshift(currentChunkIndex);
        }

        uploadNextChunk(id);
    }

    function onResumeSuccess(id, name, firstChunkIndex, persistedChunkInfoForResume) {
        firstChunkIndex = persistedChunkInfoForResume.part;
        fileState[id].loaded = persistedChunkInfoForResume.lastByteSent;
        fileState[id].estTotalRequestsSize = persistedChunkInfoForResume.estTotalRequestsSize;
        fileState[id].initialRequestOverhead = persistedChunkInfoForResume.initialRequestOverhead;
        fileState[id].attemptingResume = true;
        log("Resuming " + name + " at partition index " + firstChunkIndex);

        calculateRemainingChunkIdxsAndUpload(id, firstChunkIndex);
    }

    function handlePossibleResumeAttempt(id, persistedChunkInfoForResume, firstChunkIndex) {
        var name = getName(id),
            firstChunkDataForResume = internalApi.getChunkData(id, persistedChunkInfoForResume.part),
            onResumeRetVal;

        onResumeRetVal = spec.onResume(id, name, internalApi.getChunkDataForCallback(firstChunkDataForResume));
        if (onResumeRetVal instanceof qq.Promise) {
            log("Waiting for onResume promise to be fulfilled for " + id);
            onResumeRetVal.then(
                function() {
                    onResumeSuccess(id, name, firstChunkIndex, persistedChunkInfoForResume);
                },
                function() {
                    log("onResume promise fulfilled - failure indicated.  Will not resume.");
                    calculateRemainingChunkIdxsAndUpload(id, firstChunkIndex);
                }
            );
        }
        else if (onResumeRetVal !== false) {
            onResumeSuccess(id, name, firstChunkIndex, persistedChunkInfoForResume);
        }
        else {
            log("onResume callback returned false.  Will not resume.");
            calculateRemainingChunkIdxsAndUpload(id, firstChunkIndex);
        }
    }

    function handleFileChunkingUpload(id, retry) {
        var firstChunkIndex = 0,
            persistedChunkInfoForResume;

        if (!fileState[id].remainingChunkIdxs || fileState[id].remainingChunkIdxs.length === 0) {
            fileState[id].remainingChunkIdxs = [];

            if (resumeEnabled && !retry && fileState[id].file) {
                persistedChunkInfoForResume = getPersistedChunkData(id);
                if (persistedChunkInfoForResume) {
                    handlePossibleResumeAttempt(id, persistedChunkInfoForResume, firstChunkIndex);
                }
                else {
                    calculateRemainingChunkIdxsAndUpload(id, firstChunkIndex);
                }
            }
            else {
                calculateRemainingChunkIdxsAndUpload(id, firstChunkIndex);
            }
        }
        else {
            uploadNextChunk(id);
        }
    }

    function handleStandardFileUpload(id) {
        var fileOrBlob = fileState[id].file || fileState[id].blobData.blob,
            name = getName(id),
            xhr, params, toSend;

        fileState[id].loaded = 0;

        xhr = internalApi.createXhr(id);

        xhr.upload.onprogress = function(e){
            if (e.lengthComputable){
                fileState[id].loaded = e.loaded;
                spec.onProgress(id, name, e.loaded, e.total);
            }
        };

        xhr.onreadystatechange = getReadyStateChangeHandler(id, xhr);

        params = spec.paramsStore.getParams(id);
        toSend = setParamsAndGetEntityToSend(params, xhr, fileOrBlob, id);
        setHeaders(id, xhr);

        log("Sending upload request for " + id);
        xhr.send(toSend);
    }

    function handleUploadSignal(id, retry) {
        var name = getName(id);

        if (publicApi.isValid(id)) {
            spec.onUpload(id, name);

            if (chunkFiles) {
                handleFileChunkingUpload(id, retry);
            }
            else {
                handleStandardFileUpload(id);
            }
        }
    }


    qq.extend(this, new qq.UploadHandlerXhrApi(
        internalApi,
        {fileState: fileState, chunking: chunkFiles ? spec.chunking : null},
        {onUpload: handleUploadSignal, onCancel: spec.onCancel, onUuidChanged: onUuidChanged, getName: getName,
            getSize: getSize, getUuid: getUuid, log: log}
    ));

    // Base XHR API overrides
    qq.override(this, function(super_) {
        return {
            add: function(id, fileOrBlobData) {
                var persistedChunkData;

                super_.add.apply(this, arguments);

                if (resumeEnabled) {
                    persistedChunkData = getPersistedChunkData(id);

                    if (persistedChunkData) {
                        onUuidChanged(id, persistedChunkData.uuid);
                    }
                }

                return id;
            },

            getResumableFilesData: function() {
                var matchingCookieNames = [],
                    resumableFilesData = [];

                if (chunkFiles && resumeEnabled) {
                    if (resumeId === undefined) {
                        matchingCookieNames = qq.getCookieNames(new RegExp("^qqfilechunk\\" + cookieItemDelimiter + ".+\\" +
                            cookieItemDelimiter + "\\d+\\" + cookieItemDelimiter + spec.chunking.partSize + "="));
                    }
                    else {
                        matchingCookieNames = qq.getCookieNames(new RegExp("^qqfilechunk\\" + cookieItemDelimiter + ".+\\" +
                            cookieItemDelimiter + "\\d+\\" + cookieItemDelimiter + spec.chunking.partSize + "\\" +
                            cookieItemDelimiter + resumeId + "="));
                    }

                    qq.each(matchingCookieNames, function(idx, cookieName) {
                        var cookiesNameParts = cookieName.split(cookieItemDelimiter);
                        var cookieValueParts = qq.getCookie(cookieName).split(cookieItemDelimiter);

                        resumableFilesData.push({
                            name: decodeURIComponent(cookiesNameParts[1]),
                            size: cookiesNameParts[2],
                            uuid: cookieValueParts[0],
                            partIdx: cookieValueParts[1]
                        });
                    });

                    return resumableFilesData;
                }
                return [];
            },

            expunge: function(id) {
                if (resumeEnabled) {
                    deletePersistedChunkData(id);
                }

                super_.expunge(id);
            }
        };
    });
};

/*globals qq, document, CustomEvent*/
qq.DragAndDrop = function(o) {
    "use strict";

    var options,
        HIDE_ZONES_EVENT_NAME = "qq-hidezones",
        HIDE_BEFORE_ENTER_ATTR = "qq-hide-dropzone",
        uploadDropZones = [],
        droppedFiles = [],
        disposeSupport = new qq.DisposeSupport();

    options = {
        dropZoneElements: [],
        allowMultipleItems: true,
        classes: {
            dropActive: null
        },
        callbacks: new qq.DragAndDrop.callbacks()
    };

    qq.extend(options, o, true);

    function uploadDroppedFiles(files, uploadDropZone) {
        // We need to convert the `FileList` to an actual `Array` to avoid iteration issues
        var filesAsArray = Array.prototype.slice.call(files);

        options.callbacks.dropLog("Grabbed " + files.length + " dropped files.");
        uploadDropZone.dropDisabled(false);
        options.callbacks.processingDroppedFilesComplete(filesAsArray, uploadDropZone.getElement());
    }

    function traverseFileTree(entry) {
        var dirReader,
            parseEntryPromise = new qq.Promise();

        if (entry.isFile) {
            entry.file(function(file) {
                droppedFiles.push(file);
                parseEntryPromise.success();
            },
            function(fileError) {
                options.callbacks.dropLog("Problem parsing '" + entry.fullPath + "'.  FileError code " + fileError.code + ".", "error");
                parseEntryPromise.failure();
            });
        }
        else if (entry.isDirectory) {
            dirReader = entry.createReader();
            dirReader.readEntries(function(entries) {
                var entriesLeft = entries.length;

                qq.each(entries, function(idx, entry) {
                    traverseFileTree(entry).done(function() {
                        entriesLeft-=1;

                        if (entriesLeft === 0) {
                            parseEntryPromise.success();
                        }
                    });
                });

                if (!entries.length) {
                    parseEntryPromise.success();
                }
            }, function(fileError) {
                options.callbacks.dropLog("Problem parsing '" + entry.fullPath + "'.  FileError code " + fileError.code + ".", "error");
                parseEntryPromise.failure();
            });
        }

        return parseEntryPromise;
    }

    function handleDataTransfer(dataTransfer, uploadDropZone) {
        var pendingFolderPromises = [],
            handleDataTransferPromise = new qq.Promise();

        options.callbacks.processingDroppedFiles();
        uploadDropZone.dropDisabled(true);

        if (dataTransfer.files.length > 1 && !options.allowMultipleItems) {
            options.callbacks.processingDroppedFilesComplete([]);
            options.callbacks.dropError("tooManyFilesError", "");
            uploadDropZone.dropDisabled(false);
            handleDataTransferPromise.failure();
        }
        else {
            droppedFiles = [];

            if (qq.isFolderDropSupported(dataTransfer)) {
                qq.each(dataTransfer.items, function(idx, item) {
                    var entry = item.webkitGetAsEntry();

                    if (entry) {
                        //due to a bug in Chrome's File System API impl - #149735
                        if (entry.isFile) {
                            droppedFiles.push(item.getAsFile());
                        }

                        else {
                            pendingFolderPromises.push(traverseFileTree(entry).done(function() {
                                pendingFolderPromises.pop();
                                if (pendingFolderPromises.length === 0) {
                                    handleDataTransferPromise.success();
                                }
                            }));
                        }
                    }
                });
            }
            else {
                droppedFiles = dataTransfer.files;
            }

            if (pendingFolderPromises.length === 0) {
                handleDataTransferPromise.success();
            }
        }

        return handleDataTransferPromise;
    }

    function setupDropzone(dropArea) {
        var dropZone = new qq.UploadDropZone({
            HIDE_ZONES_EVENT_NAME: HIDE_ZONES_EVENT_NAME,
            element: dropArea,
            onEnter: function(e){
                qq(dropArea).addClass(options.classes.dropActive);
                e.stopPropagation();
            },
            onLeaveNotDescendants: function(e){
                qq(dropArea).removeClass(options.classes.dropActive);
            },
            onDrop: function(e){
                handleDataTransfer(e.dataTransfer, dropZone).done(function() {
                    uploadDroppedFiles(droppedFiles, dropZone);
                });
            }
        });

        disposeSupport.addDisposer(function() {
            dropZone.dispose();
        });

        qq(dropArea).hasAttribute(HIDE_BEFORE_ENTER_ATTR) && qq(dropArea).hide();

        uploadDropZones.push(dropZone);

        return dropZone;
    }

    function isFileDrag(dragEvent) {
        var fileDrag;

        qq.each(dragEvent.dataTransfer.types, function(key, val) {
            if (val === "Files") {
                fileDrag = true;
                return false;
            }
        });

        return fileDrag;
    }

    function leavingDocumentOut(e) {
        /* jshint -W041, eqeqeq:false */
            // null coords for Chrome and Safari Windows
        return ((qq.chrome() || (qq.safari() && qq.windows())) && e.clientX == 0 && e.clientY == 0) ||
            // null e.relatedTarget for Firefox
            (qq.firefox() && !e.relatedTarget);
    }

    function setupDragDrop() {
        var dropZones = options.dropZoneElements;

        qq.each(dropZones, function(idx, dropZone) {
            var uploadDropZone = setupDropzone(dropZone);

            // IE <= 9 does not support the File API used for drag+drop uploads
            if (dropZones.length && (!qq.ie() || qq.ie10())) {
                disposeSupport.attach(document, "dragenter", function(e) {
                    if (!uploadDropZone.dropDisabled() && isFileDrag(e)) {
                        qq.each(dropZones, function(idx, dropZone) {
                            // We can't apply styles to non-HTMLElements, since they lack the `style` property
                            if (dropZone instanceof HTMLElement) {
                                qq(dropZone).css({display: "block"});
                            }
                        });
                    }
                });
            }
        });

        disposeSupport.attach(document, "dragleave", function(e) {
            if (leavingDocumentOut(e)) {
                qq.each(dropZones, function(idx, dropZone) {
                    qq(dropZone).hasAttribute(HIDE_BEFORE_ENTER_ATTR) && qq(dropZone).hide();
                });
            }
        });

        disposeSupport.attach(document, "drop", function(e){
            qq.each(dropZones, function(idx, dropZone) {
                qq(dropZone).hasAttribute(HIDE_BEFORE_ENTER_ATTR) && qq(dropZone).hide();
            });
            e.preventDefault();
        });

        disposeSupport.attach(document, HIDE_ZONES_EVENT_NAME, function(e) {
            qq.each(options.dropZoneElements, function(idx, zone) {
                qq(zone).hasAttribute(HIDE_BEFORE_ENTER_ATTR) && qq(zone).hide();
                qq(zone).removeClass(options.classes.dropActive);
            });
        });
    }

    setupDragDrop();

    qq.extend(this, {
        setupExtraDropzone: function(element) {
            options.dropZoneElements.push(element);
            setupDropzone(element);
        },

        removeDropzone: function(element) {
            var i,
                dzs = options.dropZoneElements;

            for(i in dzs) {
                if (dzs[i] === element) {
                    return dzs.splice(i, 1);
                }
            }
        },

        dispose: function() {
            disposeSupport.dispose();
            qq.each(uploadDropZones, function(idx, dropZone) {
                dropZone.dispose();
            });
        }
    });
};

qq.DragAndDrop.callbacks = function() {
    "use strict";

    return {
        processingDroppedFiles: function() {},
        processingDroppedFilesComplete: function(files, targetEl) {},
        dropError: function(code, errorSpecifics) {
            qq.log("Drag & drop error code '" + code + " with these specifics: '" + errorSpecifics + "'", "error");
        },
        dropLog: function(message, level) {
            qq.log(message, level);
        }
    };
};

qq.UploadDropZone = function(o){
    "use strict";

    var disposeSupport = new qq.DisposeSupport(),
        options, element, preventDrop, dropOutsideDisabled;

    options = {
        element: null,
        onEnter: function(e){},
        onLeave: function(e){},
        // is not fired when leaving element by hovering descendants
        onLeaveNotDescendants: function(e){},
        onDrop: function(e){}
    };

    qq.extend(options, o);
    element = options.element;

    function dragover_should_be_canceled(){
        return qq.safari() || (qq.firefox() && qq.windows());
    }

    function disableDropOutside(e){
        // run only once for all instances
        if (!dropOutsideDisabled ){

            // for these cases we need to catch onDrop to reset dropArea
            if (dragover_should_be_canceled){
                disposeSupport.attach(document, "dragover", function(e){
                    e.preventDefault();
                });
            } else {
                disposeSupport.attach(document, "dragover", function(e){
                    if (e.dataTransfer){
                        e.dataTransfer.dropEffect = "none";
                        e.preventDefault();
                    }
                });
            }

            dropOutsideDisabled = true;
        }
    }

    function isValidFileDrag(e){
        // e.dataTransfer currently causing IE errors
        // IE9 does NOT support file API, so drag-and-drop is not possible
        if (qq.ie() && !qq.ie10()) {
            return false;
        }

        var effectTest, dt = e.dataTransfer,
        // do not check dt.types.contains in webkit, because it crashes safari 4
        isSafari = qq.safari();

        // dt.effectAllowed is none in Safari 5
        // dt.types.contains check is for firefox

        // dt.effectAllowed crashes IE11 when files have been dragged from
        // the filesystem
        effectTest = (qq.ie10() || qq.ie11()) ? true : dt.effectAllowed !== "none";
        return dt && effectTest && (dt.files || (!isSafari && dt.types.contains && dt.types.contains("Files")));
    }

    function isOrSetDropDisabled(isDisabled) {
        if (isDisabled !== undefined) {
            preventDrop = isDisabled;
        }
        return preventDrop;
    }

    function triggerHidezonesEvent() {
        var hideZonesEvent;

        function triggerUsingOldApi() {
            hideZonesEvent = document.createEvent("Event");
            hideZonesEvent.initEvent(options.HIDE_ZONES_EVENT_NAME, true, true);
        }

        if (window.CustomEvent) {
            try {
                hideZonesEvent = new CustomEvent(options.HIDE_ZONES_EVENT_NAME);
            }
            catch (err) {
                triggerUsingOldApi();
            }
        }
        else {
            triggerUsingOldApi();
        }

        document.dispatchEvent(hideZonesEvent);
    }

    function attachEvents(){
        disposeSupport.attach(element, "dragover", function(e){
            if (!isValidFileDrag(e)) {
                return;
            }

            // dt.effectAllowed crashes IE11 when files have been dragged from
            // the filesystem
            var effect = (qq.ie() || qq.ie11()) ? null : e.dataTransfer.effectAllowed;
            if (effect === "move" || effect === "linkMove"){
                e.dataTransfer.dropEffect = "move"; // for FF (only move allowed)
            } else {
                e.dataTransfer.dropEffect = "copy"; // for Chrome
            }

            e.stopPropagation();
            e.preventDefault();
        });

        disposeSupport.attach(element, "dragenter", function(e){
            if (!isOrSetDropDisabled()) {
                if (!isValidFileDrag(e)) {
                    return;
                }
                options.onEnter(e);
            }
        });

        disposeSupport.attach(element, "dragleave", function(e){
            if (!isValidFileDrag(e)) {
                return;
            }

            options.onLeave(e);

            var relatedTarget = document.elementFromPoint(e.clientX, e.clientY);
            // do not fire when moving a mouse over a descendant
            if (qq(this).contains(relatedTarget)) {
                return;
            }

            options.onLeaveNotDescendants(e);
        });

        disposeSupport.attach(element, "drop", function(e) {
            if (!isOrSetDropDisabled()) {
                if (!isValidFileDrag(e)) {
                    return;
                }

                e.preventDefault();
                e.stopPropagation();
                options.onDrop(e);

                triggerHidezonesEvent();
            }
        });
    }

    disableDropOutside();
    attachEvents();

    qq.extend(this, {
        dropDisabled: function(isDisabled) {
            return isOrSetDropDisabled(isDisabled);
        },

        dispose: function() {
            disposeSupport.dispose();
        },

        getElement: function() {
            return element;
        }
    });
};

/*globals jQuery, qq*/
(function($) {
    "use strict";
    var $el,
        pluginOptions = ["uploaderType", "endpointType"];

    function init(options) {
        if (options) {
            var xformedOpts = transformVariables(options),
                newUploaderInstance = getNewUploaderInstance(xformedOpts);

            uploader(newUploaderInstance);
            addCallbacks(xformedOpts, newUploaderInstance);
        }

        return $el;
    }

    function getNewUploaderInstance(params) {
        var uploaderType = pluginOption("uploaderType"),
            namespace = pluginOption("endpointType");

        // If the integrator has defined a specific type of uploader to load, use that, otherwise assume `qq.FineUploader`
        if (uploaderType) {
            // We can determine the correct constructor function to invoke by combining "FineUploader"
            // with the upper camel cased `uploaderType` value.
            uploaderType = uploaderType.charAt(0).toUpperCase() + uploaderType.slice(1).toLowerCase();

            if (namespace) {
                return new qq[namespace]["FineUploader" + uploaderType](params);
            }

            return new qq["FineUploader" + uploaderType](params);
        }
        else {
            if (namespace) {
                return new qq[namespace].FineUploader(params);
            }

            return new qq.FineUploader(params);
        }
    }

    function dataStore(key, val) {
        var data = $el.data("fineuploader");

        if (val) {
            if (data === undefined) {
                data = {};
            }
            data[key] = val;
            $el.data("fineuploader", data);
        }
        else {
            if (data === undefined) {
                return null;
            }
            return data[key];
        }
    }

    //the underlying Fine Uploader instance is stored in jQuery's data stored, associated with the element
    // tied to this instance of the plug-in
    function uploader(instanceToStore) {
        return dataStore("uploader", instanceToStore);
    }

    function pluginOption(option, optionVal) {
        return dataStore(option, optionVal);
    }

    // Implement all callbacks defined in Fine Uploader as functions that trigger appropriately names events and
    // return the result of executing the bound handler back to Fine Uploader
    function addCallbacks(transformedOpts, newUploaderInstance) {
        var callbacks = transformedOpts.callbacks = {};

        $.each(newUploaderInstance._options.callbacks, function(prop, nonJqueryCallback) {
            var name, callbackEventTarget;

            name = /^on(\w+)/.exec(prop)[1];
            name = name.substring(0, 1).toLowerCase() + name.substring(1);
            callbackEventTarget = $el;

            callbacks[prop] = function() {
                var originalArgs = Array.prototype.slice.call(arguments),
                    transformedArgs = [],
                    nonJqueryCallbackRetVal, jqueryEventCallbackRetVal;

                $.each(originalArgs, function(idx, arg) {
                    transformedArgs.push(maybeWrapInJquery(arg));
                });

                nonJqueryCallbackRetVal = nonJqueryCallback.apply(this, originalArgs);

                try {
                    jqueryEventCallbackRetVal = callbackEventTarget.triggerHandler(name, transformedArgs);
                }
                catch (error) {
                    qq.log("Caught error in Fine Uploader jQuery event handler: " + error.message, "error");
                }

                /*jshint -W116*/
                if (nonJqueryCallbackRetVal != null) {
                    return nonJqueryCallbackRetVal;
                }
                return jqueryEventCallbackRetVal;
            };
        });

        newUploaderInstance._options.callbacks = callbacks;
    }

    //transform jQuery objects into HTMLElements, and pass along all other option properties
    function transformVariables(source, dest) {
        var xformed, arrayVals;

        if (dest === undefined) {
            if (source.uploaderType !== "basic") {
                xformed = { element : $el[0] };
            }
            else {
                xformed = {};
            }
        }
        else {
            xformed = dest;
        }

        $.each(source, function(prop, val) {
            if ($.inArray(prop, pluginOptions) >= 0) {
                pluginOption(prop, val);
            }
            else if (val instanceof $) {
                xformed[prop] = val[0];
            }
            else if ($.isPlainObject(val)) {
                xformed[prop] = {};
                transformVariables(val, xformed[prop]);
            }
            else if ($.isArray(val)) {
                arrayVals = [];
                $.each(val, function(idx, arrayVal) {
                    var arrayObjDest = {};

                    if (arrayVal instanceof $) {
                        $.merge(arrayVals, arrayVal);
                    }
                    else if ($.isPlainObject(arrayVal)) {
                        transformVariables(arrayVal, arrayObjDest);
                        arrayVals.push(arrayObjDest);
                    }
                    else {
                        arrayVals.push(arrayVal);
                    }
                });
                xformed[prop] = arrayVals;
            }
            else {
                xformed[prop] = val;
            }
        });

        if (dest === undefined) {
            return xformed;
        }
    }

    function isValidCommand(command) {
        return $.type(command) === "string" &&
            !command.match(/^_/) && //enforce private methods convention
            uploader()[command] !== undefined;
    }

    // Assuming we have already verified that this is a valid command, call the associated function in the underlying
    // Fine Uploader instance (passing along the arguments from the caller) and return the result of the call back to the caller
    function delegateCommand(command) {
        var xformedArgs = [],
            origArgs = Array.prototype.slice.call(arguments, 1),
            retVal;

        transformVariables(origArgs, xformedArgs);

        retVal = uploader()[command].apply(uploader(), xformedArgs);

        return maybeWrapInJquery(retVal);
    }

    // If the value is an `HTMLElement` or `HTMLDocument`, wrap it in a `jQuery` object
    function maybeWrapInJquery(val) {
        var transformedVal = val;

        // If the command is returning an `HTMLElement` or `HTMLDocument`, wrap it in a `jQuery` object
        /*jshint -W116*/
        if (val != null && typeof val === "object" &&
           (val.nodeType === 1 || val.nodeType === 9) && val.cloneNode) {

            transformedVal = $(val);
        }

        return transformedVal;
    }

    $.fn.fineUploader = function(optionsOrCommand) {
        var self = this, selfArgs = arguments, retVals = [];

        this.each(function(index, el) {
            $el = $(el);

            if (uploader() && isValidCommand(optionsOrCommand)) {
                retVals.push(delegateCommand.apply(self, selfArgs));

                if (self.length === 1) {
                    return false;
                }
            }
            else if (typeof optionsOrCommand === "object" || !optionsOrCommand) {
                init.apply(self, selfArgs);
            }
            else {
                $.error("Method " +  optionsOrCommand + " does not exist on jQuery.fineUploader");
            }
        });

        if (retVals.length === 1) {
            return retVals[0];
        }
        else if (retVals.length > 1) {
            return retVals;
        }

        return this;
    };

}(eds1_10));

/*globals jQuery, qq*/
(function($) {
    "use strict";
    var rootDataKey = "fineUploaderDnd",
        $el;

    function init (options) {
        if (!options) {
            options = {};
        }

        options.dropZoneElements = [$el];
        var xformedOpts = transformVariables(options);
        addCallbacks(xformedOpts);
        dnd(new qq.DragAndDrop(xformedOpts));

        return $el;
    }

    function dataStore(key, val) {
        var data = $el.data(rootDataKey);

        if (val) {
            if (data === undefined) {
                data = {};
            }
            data[key] = val;
            $el.data(rootDataKey, data);
        }
        else {
            if (data === undefined) {
                return null;
            }
            return data[key];
        }
    }

    function dnd(instanceToStore) {
        return dataStore("dndInstance", instanceToStore);
    }

    function addCallbacks(transformedOpts) {
        var callbacks = transformedOpts.callbacks = {},
            dndInst = new qq.FineUploaderBasic();

        $.each(new qq.DragAndDrop.callbacks(), function(prop, func) {
            var name = prop,
                $callbackEl;

            $callbackEl = $el;

            callbacks[prop] = function() {
                var args = Array.prototype.slice.call(arguments),
                    jqueryHandlerResult = $callbackEl.triggerHandler(name, args);

                return jqueryHandlerResult;
            };
        });
    }

    //transform jQuery objects into HTMLElements, and pass along all other option properties
    function transformVariables(source, dest) {
        var xformed, arrayVals;

        if (dest === undefined) {
            xformed = {};
        }
        else {
            xformed = dest;
        }

        $.each(source, function(prop, val) {
            if (val instanceof $) {
                xformed[prop] = val[0];
            }
            else if ($.isPlainObject(val)) {
                xformed[prop] = {};
                transformVariables(val, xformed[prop]);
            }
            else if ($.isArray(val)) {
                arrayVals = [];
                $.each(val, function(idx, arrayVal) {
                    if (arrayVal instanceof $) {
                        $.merge(arrayVals, arrayVal);
                    }
                    else {
                        arrayVals.push(arrayVal);
                    }
                });
                xformed[prop] = arrayVals;
            }
            else {
                xformed[prop] = val;
            }
        });

        if (dest === undefined) {
            return xformed;
        }
    }

    function isValidCommand(command) {
        return $.type(command) === "string" &&
            command === "dispose" &&
            dnd()[command] !== undefined;
    }

    function delegateCommand(command) {
        var xformedArgs = [], origArgs = Array.prototype.slice.call(arguments, 1);
        transformVariables(origArgs, xformedArgs);
        return dnd()[command].apply(dnd(), xformedArgs);
    }

    $.fn.fineUploaderDnd = function(optionsOrCommand) {
        var self = this, selfArgs = arguments, retVals = [];

        this.each(function(index, el) {
            $el = $(el);

            if (dnd() && isValidCommand(optionsOrCommand)) {
                retVals.push(delegateCommand.apply(self, selfArgs));

                if (self.length === 1) {
                    return false;
                }
            }
            else if (typeof optionsOrCommand === "object" || !optionsOrCommand) {
                init.apply(self, selfArgs);
            }
            else {
                $.error("Method " +  optionsOrCommand + " does not exist in Fine Uploader's DnD module.");
            }
        });

        if (retVals.length === 1) {
            return retVals[0];
        }
        else if (retVals.length > 1) {
            return retVals;
        }

        return this;
    };

}(eds1_10));

/*! 2014-01-23 */
