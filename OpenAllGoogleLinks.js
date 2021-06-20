let hidden = null;

if (typeof document.hidden !== "undefined") { // Opera 12.10 and Firefox 18 and later support
    hidden = "hidden";
} else if (typeof document["msHidden"] !== "undefined") {
    hidden = "msHidden";
} else if (typeof document["webkitHidden"] !== "undefined") {
    hidden = "webkitHidden";
}

function fakeClick(anchorObj, event) {
    try {

        if (anchorObj.click) {
            anchorObj.click()
        } else if (document.createEvent) {
            if (!event || event.target !== anchorObj) {
                var evt = document.createEvent("MouseEvents");
                evt.initMouseEvent("click", true, true, window,
                    0, 0, 0, 0, 0, false, false, false, false, 0, null);
                var allowDefault = anchorObj.dispatchEvent(evt);
                // you can check allowDefault for false to see if
                // any handler called evt.preventDefault().
                // Firefox will *not* redirect to anchorObj.href
                // for you. However every other browser will.
            }
        }
    } catch (e) {
        debugger;
    }
}

let visibilityChange = null;

if (typeof document.hidden !== "undefined") { // Opera 12.10 and Firefox 18 and later support
    visibilityChange = "visibilitychange";
} else if (typeof document["msHidden"] !== "undefined") {
    visibilityChange = "msvisibilitychange";
} else if (typeof document["webkitHidden"] !== "undefined") {
    visibilityChange = "webkitvisibilitychange";
}


function onVisibilityChanged(e) {

    if (!hidden) return;

    if (document[hidden]) {

    } else {

        let a = document.getElementsByTagName('span');

        let i2 = 0;
        while (window.queueUrls.length > 0 && i2++ < 10) {

            window.open(window.queueUrls.pop());
        }

        if (window.queueUrls.length === 0)
            for (let i = 0; i < a.length; i++) {

                if (a[i].innerText === "Next" || a[i].innerText === "Volgende") {

                    fakeClick(a[i]);
                    break;
                }
            }
    }
}

data.more = false;
data.done = !!data.done ? data.done : [];
data.urls = [];
window.queueUrls = !!window.queueUrls ? window.queueUrls : [];

let a = document.getElementsByTagName('a');

if (!window.onceOnly) {

    window.onceOnly = true;
    document.removeEventListener("visibilitychange", onVisibilityChanged);
    document.addEventListener("visibilitychange", onVisibilityChanged, { passive: false });

    let i2 = 0;
    for (let i = 0; i < a.length; i++) {

        try {
            let b = a[i].getAttribute('href');

            if (!!b && (typeof b === 'string') && b !== '' && b.substr(0, 1) !== '#' && b.indexOf('google') < 0 && data.done.indexOf(b) < 0) {

                if (b.indexOf('/search?') === 0) {

                    continue;
                }

                if (i2++ < 10) {
                    window.open(b);
                } else {
                    window.queueUrls.push(b);
                }
            }
        } catch (e) {

        }
    }
}

a = document.getElementsByTagName('span');
for (let i = 0; i < a.length; i++) {

    if (a[i].innerText === "Next" || a[i].innerText === "Volgende") {

        data.more = true;
        break;
    }
}