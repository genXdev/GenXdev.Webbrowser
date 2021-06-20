data.done = !!data.done ? data.done : [];
data.urls = [];

let a = document.getElementsByTagName('a');
let c = '';
for (let i = 0; i < a.length; i++) {

    try {
        let b = a[i].getAttribute('href');

        if (!!b && (typeof b === 'string') && b !== '' && b.substr(0, 1) !== '#' && b.indexOf('google') < 0) {

            if (b.indexOf('/search?') === 0) {

                if (data.done.indexOf(b) < 0 && b.indexOf(encodeURIComponent(data.query)) > 0) {

                    c = "https://www.google.com" + b;
                }

                continue;
            }

            data.urls.push(b);
        }
    } catch (e) {

    }
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

a = document.getElementsByTagName('span');
for (let i = 0; i < a.length; i++) {

    if (a[i].innerText === "Next" || a[i].innerText === "Volgende") {

        fakeClick(a[i]);
        data.more = true;
        c = null;
        break;
    }
}

if (c !== null) {

    if (c !== '') {

        data.more = true;
        data.done.push(c);
        document.location.href = c;
    } else {

        data.more = false;
    }
}