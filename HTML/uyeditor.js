/*
 * UYEditor v0.3
 */

var uyeditor = {};

uyeditor.blankText = '<p><br></p>';
uyeditor.isBackSpaceDown = false;
uyeditor.isDragging = false;

// #init

init = function() {
    document.execCommand('insertBrOnReturn', false, false);
    document.execCommand('defaultParagraphSeparator', false, 'p');
    
    uyeditor.setPlaceholder(null);
    uyeditor.setHTML(null);

    // Make sure that when we tap anywhere in the document we focus on the editor
    $(window).on('touchmove', function(e) {
        uyeditor.isDragging = true;
    });
    
    $(window).on('touchstart', function(e) {
        uyeditor.isDragging = false;
    });

    $(window).on('touchend', function(e) {
        if (uyeditor.isDragging) return;

        var isEditable = uyeditor.isEditable();
        var hasFocus = uyeditor.hasFocus();
        var target = e.target.nodeName.toLowerCase();
        if (!hasFocus && isEditable && (target == 'html' || target == 'body')) {
            uyeditor.focusEditor();
        };
    });
    
    $(document).on('touchend', function(e) {
        var isEditable = uyeditor.isEditable();
        if (isEditable && !uyeditor.isDragging) {
            var html = uyeditor.getHTML();
            var target = e.target.nodeName.toLowerCase();
                  
            if (target == 'img') {
                e.preventDefault();
                var editor = $('#editor_content');
                var range = document.createRange();
                range.setStartAfter($(e.target).get(0));
                range.collapse(false);
                var selection = window.getSelection();
                selection.removeAllRanges();
                selection.addRange(range);
            }
        }
    });
    
    $(document).bind('input', function(e) {
        if(uyeditor.isBackSpaceDown) {
            if(uyeditor.isHTMLBlank()) {
                uyeditor.setHTML(uyeditor.blankText);
                uyeditor.focusEditor();
            }
        }
        updatePlaceholder();
        callbackInput();
    });
    
    $(document).on('selectionchange',function(e){
        callbackSelection();
        sendEnabledStyles();
    });

    var el = document.getElementById("editor_content");
    if (typeof el.addEventListener != "undefined") {
        el.addEventListener("keydown", keyDownHandler, false);
        el.addEventListener("keyup", keyUpHandler, false);
    } else if (typeof el.attachEvent != "undefined") {
        el.attachEvent("keydown", keyDownHandler);
        el.addEventListener("onkeyup", keyUpHandler, false);
    }
}

bindImageLoadEvent = function() {
    $('img').each(function(){
        var img = new Image();
        img.onload = function() {
            //console.log($(this).attr('src') + ' - done!');
            callbackContentHeightUpdated();
        }
        img.src = $(this).attr('src');
    });
}

updatePlaceholder = function() {
    var placeholder = $('#editor_placeholder');
    if(uyeditor.isHTMLBlank()) {
        placeholder.show();
    } else {
        placeholder.hide();
    }
}

keyDownHandler = function(evt) {
    var key = evt.which || evt.keyCode || evt.charCode;
    if (key == '8') {
        uyeditor.isBackSpaceDown = true;
        var html = uyeditor.getHTML();
        if(html == uyeditor.blankText) {
            evt.preventDefault();
        }
    } else if (key == '13') {
        var html = uyeditor.getHTML();
        if(!html || html == uyeditor.blankText) {
            evt.preventDefault();
        }
    }
}

keyUpHandler = function (evt){
    var key = evt.which || evt.keyCode || evt.charCode;
    if (key == '8') {
        uyeditor.isBackSpaceDown = false;
    }
}

// #Call back

/**
 *  @brief      Executes a callback by loading it into an IFrame.
 *  @details    The reason why we're using this instead of window.location is that window.location
 *              can sometimes fail silently when called multiple times in rapid succession.
 *              Found here:
 *              http://stackoverflow.com/questions/10010342/clicking-on-a-link-inside-a-webview-that-will-trigger-a-native-ios-screen-with/10080969#10080969
 *
 *  @param      url     The callback URL.
 */
callback = function(url) {
    var iframe = document.createElement("IFRAME");
    iframe.setAttribute("src", url);
    
    // IMPORTANT: the IFrame was showing up as a black box below our text.  By setting its borders
    // to be 0px transparent we make sure it's not shown at all.
    //
    // REF BUG: https://github.com/wordpress-mobile/WordPress-iOS-Editor/issues/318
    //
    iframe.style.cssText = "border: 0px transparent;";

    document.documentElement.appendChild(iframe);
    iframe.parentNode.removeChild(iframe);
    iframe = null;
};

debug = function(msg) {
    callback('debug://' + msg);
}

callbackStyle = function(msg) {
    callback('styles://' + msg);
}

callbackInput = function(e) {
    callback('input://');
}

callbackSelection = function() {
    callback('selection://');
}

callbackContentHeightUpdated = function() {
    var height = $(editor_footer).position().top + $(editor_footer).height();
    callback('contentheight://' + height);
}

// #Command API
isCommandEnabled = function(commandName) {
    return document.queryCommandState(commandName);
};

sendEnabledStyles = function(e) {
    var items = [];
    if (isCommandEnabled('bold')) {
        items.push('bold');
    }
    if (isCommandEnabled('italic')) {
        items.push('italic');
    }
    if (isCommandEnabled('subscript')) {
        items.push('subscript');
    }
    if (isCommandEnabled('superscript')) {
        items.push('superscript');
    }
    if (isCommandEnabled('strikeThrough')) {
        items.push('strikeThrough');
    }
    if (isCommandEnabled('underline')) {
        // DRM: 'underline' gets highlighted if it's inside of a link... so we need a special test
        // in that case.
        items.push('underline');
    }
    if (isCommandEnabled('insertOrderedList')) {
        items.push('insertOrderedList');
    }
    if (isCommandEnabled('insertUnorderedList')) {
        items.push('insertUnorderedList');
    }
    
    callbackStyle(items.join(','));
}

// #Public functions

/**
 *  "bold",
 *  "italic",
 *  "subscript",
 *  "superscript",
 *  "strikeThrough",
 *  "underline",
 *  "insertUnorderedList",
 *  "insertOrderedList",
 */
uyeditor.command = function(a, p) {
    var result;
    if (p === null) {
        p = false;
    }
    if (a === "blockquote" || a === "pre") {
        p = a;
        a = "formatBlock";
    }
    if (document.queryCommandState(a) === true) {
        result = document.execCommand(a, false, null);
    } else {
        result = document.execCommand(a, false, p);
    }
    sendEnabledStyles();
    return result;
}

uyeditor.isEditable = function() {
    return document.getElementById('editor_content').getAttribute('contenteditable') == 'true';
}

uyeditor.setEditable = function(editable) {
    document.getElementById('editor_content').setAttribute('contenteditable', Boolean(editable));
}

uyeditor.setPlaceholder = function(placeholder) {
    var html = placeholder ? '<p>' + placeholder + '</p>' : '';
    $('#editor_placeholder').html(html);
}

uyeditor.setHTML = function(html) {
    var editor = $('#editor_content');

    if(!html || html == '' || html == '<br>'){
        html = uyeditor.blankText;
    }
    editor.html(html);
    updatePlaceholder();
    bindImageLoadEvent();
}

uyeditor.getHTML = function() {
    var bq = $('blockquote');
    if (bq.length != 0) {
        bq.each(function() {
            var b = $(this);
            if (b.css('border').indexOf('none') != -1) {
                b.css({'border': ''});
            }
            if (b.css('padding').indexOf('0px') != -1) {
                b.css({'padding': ''});
            }
        });
    }
    var h = document.getElementById("editor_content").innerHTML;
    if (h == uyeditor.blankText) {
        h = '';
    }
    return h;
}

uyeditor.insertHTML = function(html) {
    document.execCommand('insertHTML', false, html);
    sendEnabledStyles();
}

uyeditor.insertImage = function(url, alt) {
    uyeditor.restorerange();
    var html = '<img src="'+url+'" alt="'+alt+'"/>';
    uyeditor.insertHTML(html);
    bindImageLoadEvent();
}

uyeditor.hasFocus = function() {
    return $('#editor_content').is(':focus');
}

uyeditor.focusEditor = function() {
    // the following was taken from http://stackoverflow.com/questions/1125292/how-to-move-cursor-to-end-of-contenteditable-entity/3866442#3866442
    // and ensures we move the cursor to the end of the editor
    var editor = $('#editor_content');
    var range = document.createRange();
    range.selectNodeContents(editor.get(0));
    range.collapse(false);
    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    editor.focus();
}

uyeditor.blurEditor = function() {
    var editor = $('#editor_content');
    editor.blur();
}

uyeditor.getYCaretInfo = function() {
    var caret = {top: 0, height: 0};
    caret.top = 0;
    caret.height = 0;
    var selection = window.getSelection();
    var noSelectionAvailable = selection.rangeCount == 0;
    
    if (noSelectionAvailable) {
        return null;
    }
    
    var y = 0;
    var height = 0;
    var range = selection.getRangeAt(0);
    var needsToWorkAroundNewlineBug = (range.getClientRects().length == 0);

    // PROBLEM: iOS seems to have problems getting the offset for some empty nodes and return
    // 0 (zero) as the selection range top offset.
    //
    // WORKAROUND: To fix this problem we use a different method to obtain the Y position instead.
    //
    if (needsToWorkAroundNewlineBug) {
        var span = document.createElement('span');  // something happening here preventing selection of elements
        range.insertNode(span);
        var topPosition = span.offsetTop;
        span.parentNode.removeChild(span);
        
        y = topPosition;
        height = range.startContainer.clientHeight;
    }else if (range.getClientRects) {
        var rects = range.getClientRects();
        if (rects.length > 0) {
            // PROBLEM: some iOS versions differ in what is returned by getClientRects()
            // Some versions return the offset from the page's top, some other return the
            // offset from the visible viewport's top.
            //
            // WORKAROUND: see if the offset of the body's top is ever negative.  If it is
            // then it means that the offset we have is relative to the body's top, and we
            // should add the scroll offset.
            //
            var addsScrollOffset = document.body.getClientRects()[0].top < 0;
            
            if (addsScrollOffset) {
                y = document.body.scrollTop;
            }
            
            y += rects[0].top;
            height = rects[0].height;
        }
    }
    caret.top = y;
    caret.height = height;

    return caret;
};


// #html中是否有文字或者img标签
uyeditor.isHTMLBlank = function() {
    var content = $('#editor_content');
    var nbsp = '\xa0';
    var text = content.text().replace(nbsp, '');
    
    if (text.length == 0) {
        var hasChildImages = (content.find('img').length > 0);
        var hasUnorderedList = (content.find('ul').length > 0);
        var hasOrderedList = (content.find('ol').length > 0);

        if (!hasChildImages && !hasUnorderedList && !hasOrderedList) {
            return true;
        }
    }
    return false;
}

// #Range backup/restore
uyeditor.backuprange = function() {
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    uyeditor.currentSelection = {"startContainer": range.startContainer, "startOffset":range.startOffset,"endContainer":range.endContainer, "endOffset":range.endOffset};
}

uyeditor.restorerange = function() {
    var selection = window.getSelection();
    selection.removeAllRanges();
    var range = document.createRange();
    range.setStart(uyeditor.currentSelection.startContainer, uyeditor.currentSelection.startOffset);
    range.setEnd(uyeditor.currentSelection.endContainer, uyeditor.currentSelection.endOffset);
    selection.addRange(range);
    uyeditor.currentSelection = null;
}

// #Header Footer
uyeditor.setHeaderHeight = function(height) {
    document.getElementById('editor_header').style.height = height + 'px';
}

uyeditor.setFooterHeight = function(height) {
    document.getElementById('editor_footer').style.height = height + 'px';
}