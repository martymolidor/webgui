insert into webguiVersion values ('5.3.0','upgrade',unix_timestamp());
delete from international where languageId=1 and namespace='WebGUI' and internationalId=844;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (844,1,'WebGUI','These macros have to do with users and logins.\r\n<p/>\r\n\r\n<b>&#94;a; or &#94;a(); - My Account Link</b><br>\r\nA link to your account information. In addition you can change the link text by creating a macro like this <b>&#94;a("Account Info");</b>. \r\n<p>\r\n\r\n<b>NOTES:</b> You can also use the special case &#94;a(linkonly); to return only the URL to the account page and nothing more. Also, the .myAccountLink style sheet class is tied to this macro.\r\n<p>\r\n\r\n\r\n<b>&#94;AdminText();</b><br>\r\nDisplays a small text message to a user who is in admin mode. Example: &#94;AdminText("You are in admin mode!");\r\n<p>\r\n\r\n<b>&#94;AdminToggle; or &#94;AdminToggle();</b><br>\r\nPlaces a link on the page which is only visible to content managers and adminstrators. The link toggles on/off admin mode. You can optionally specify other messages to display like this: &#94;AdminToggle("Edit On","Edit Off");\r\n<p>\r\n\r\n\r\n\r\n<b>&#94;GroupText();</b><br>\r\nDisplays a small text message to the user if they belong to the specified group. Example: &#94;GroupText("Visitors","You need an account to do anything cool on this site!");\r\n<p>\r\n\r\n<b>&#94;L; or &#94;L(); - Login Box</b><br>\r\nA small login form. You can also configure this macro. You can set the width of the login box like this &#94;L(20);. You can also set the message displayed after the user is logged in like this &#94;L(20,Hi &#94;a(&#94;@;);. Click %here% if you wanna log out!)\r\n<p>\r\n\r\n<b>NOTE:</b> The .loginBox style sheet class is tied to this macro.\r\n<p>\r\n\r\n<b>&#94;LoginToggle; or &#94;LoginToggle();</b><br>\r\nDisplays a "Login" or "Logout" message depending upon whether the user is logged in or not. You can optionally specify other labels like this: &#94;LoginToggle("Click here to log in.","Click here to log out.");. You can also use the special case &#94;LoginToggle(linkonly); to return only the URL with no label.\r\n<p>\r\n\r\n<b>&#94;@; - Username</b><br>\r\nThe username of the currently logged in user.\r\n<p>\r\n\r\n\r\n<b>&#94;#; - User ID</b><br>\r\nThe user id of the currently logged in user.\r\n<p>\r\n\r\n', 1050100597);
delete from template where namespace='Article' and templateId<10;
INSERT INTO template VALUES (4,'Linked Image with Caption','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if isFirstPage>\r\n<tmpl_if image.url>\r\n  <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td class=\"content\">\r\n   <table align=\"right\"><tr><td align=\"center\">\r\n   <tmpl_if linkUrl>\r\n        <a href=\"<tmpl_var linkUrl>\">\r\n      <img src=\"<tmpl_var image.url>\" border=\"0\">\r\n       <br /><tmpl_var linkTitle></a>\r\n    <tmpl_else>\r\n           <img src=\"<tmpl_var image.url>\" border=\"0\">\r\n           <br /> <tmpl_var linkTitle>\r\n   </tmpl_if>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if isLastPage>\r\n<tmpl_var attachment.box> <p />\r\n</tmpl_if>\r\n\r\n<tmpl_if isFirstPage>\r\n<tmpl_if image.url>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if multiplePages>\r\n<tmpl_var previousPage> \r\n&middot;\r\n<tmpl_var pageList>\r\n&middot;\r\n<tmpl_var nextPage>\r\n</tmpl_if>\r\n\r\n<tmpl_if isLastPage>\r\n\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n\r\n\r\n</tmpl_if>','Article');
INSERT INTO template VALUES (1,'Default Article','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if isFirstPage>\r\n<tmpl_if image.url>\r\n  <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td class=\"content\">\r\n  <img src=\"<tmpl_var image.url>\" align=\"right\" border=\"0\">\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if isLastPage>\r\n<tmpl_if linkUrl>\r\n  <tmpl_if linkTitle>\r\n    <p /><a href=\"<tmpl_var linkUrl>\"><tmpl_var linkTitle></a>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var attachment.box> <p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if multiplePages>\r\n<tmpl_var previousPage> \r\n&middot;\r\n<tmpl_var pageList>\r\n&middot;\r\n<tmpl_var nextPage>\r\n</tmpl_if>\r\n\r\n<tmpl_if isFirstPage>\r\n<tmpl_if image.url>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if isLastPage>\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n\r\n</tmpl_if>','Article');
INSERT INTO template VALUES (2,'Center Image','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if isFirstPage>\r\n<tmpl_if image.url>\r\n  <div align=\"center\"><img src=\"<tmpl_var image.url>\" border=\"0\"></div>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n<tmpl_if isLastPage>\r\n<tmpl_if linkurl>\r\n  <tmpl_if linktitle>\r\n    <p /><a href=\"<tmpl_var linkUrl>\"><tmpl_var linkTitle></a>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var attachment.box> <p />\r\n</tmpl_if>\r\n\r\n<tmpl_if multiplePages>\r\n<tmpl_var previousPage> \r\n&middot;\r\n<tmpl_var pageList>\r\n&middot;\r\n<tmpl_var nextPage>\r\n</tmpl_if>\r\n\r\n<tmpl_if isLastPage>\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n</tmpl_if>','Article');
INSERT INTO template VALUES (3,'Left Align Image','<tmpl_if displayTitle>\r\n    <h1><tmpl_var title></h1>\r\n</tmpl_if>\r\n\r\n<tmpl_if isFirstPage>\r\n<tmpl_if image.url>\r\n  <table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td class=\"content\">\r\n  <img src=\"<tmpl_var image.url>\" align=\"left\" border=\"0\">\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  <tmpl_var description><p />\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if isLastPage>\r\n<tmpl_if linkurl>\r\n  <tmpl_if linktitle>\r\n    <p /><a href=\"<tmpl_var linkUrl>\"><tmpl_var linkTitle></a>\r\n  </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_var attachment.box> <p />\r\n</tmpl_if>\r\n\r\n<tmpl_if isFirstPage>\r\n<tmpl_if image.url>\r\n  </td></tr></table>\r\n</tmpl_if>\r\n</tmpl_if>\r\n\r\n\r\n<tmpl_if multiplePages>\r\n<tmpl_var previousPage> \r\n&middot;\r\n<tmpl_var pageList>\r\n&middot;\r\n<tmpl_var nextPage>\r\n</tmpl_if>\r\n\r\n<tmpl_if isLastPage>\r\n\r\n<tmpl_if allowDiscussion>\r\n  <p><table width=\"100%\" cellspacing=\"2\" cellpadding=\"1\" border=\"0\">\r\n  <tr><td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var replies.URL>\"><tmpl_var replies.label> (<tmpl_var replies.count>)</a></td>\r\n  <td align=\"center\" width=\"50%\" class=\"tableMenu\"><a href=\"<tmpl_var post.url>\"><tmpl_var post.label></a></td></tr>\r\n  </table>\r\n</tmpl_if>\r\n\r\n</tmpl_if>','Article');
delete from international where languageId=1 and namespace='Article' and internationalId=71;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (71,1,'Article','Articles are the Swiss Army knife of WebGUI. Most pieces of static content can be added via the Article.\r\n<br><br>\r\n\r\nNOTE: You can create a multi-paged article by placing the seperator macro (^-;) at various places through-out your article.\r\n\r\n<p />\r\n<b>Template</b><br/>\r\nSelect a template to layout your article.\r\n<p />\r\n\r\n<b>Image</b><br>\r\nChoose an image (.jpg, .gif, .png) file from your hard drive. This file will be uploaded to the server and displayed in your article.\r\n<br><br>\r\n\r\n\r\n<b>Attachment</b><br>\r\nIf you wish to attach a word processor file, a zip file, or any other file for download by your users, then choose it from your hard drive.\r\n<br><br>\r\n\r\n<b>Link Title</b><br>\r\nIf you wish to add a link to your article, enter the title of the link in this field. \r\n<br><br>\r\n<i>Example:</i> Google\r\n<br><br>\r\n\r\n<b>Link URL</b><br>\r\nIf you added a link title, now add the URL (uniform resource locator) here. \r\n<br><br>\r\n<i>Example:</i> http://www.google.com\r\n\r\n<br><br>\r\n\r\n<b>Convert carriage returns?</b><br>\r\nIf you\'re publishing HTML there\'s generally no need to check this option, but if you aren\'t using HTML and you want a carriage return every place you hit your "Enter" key, then check this option.\r\n<p>\r\n\r\n<b>Allow discussion?</b><br>\r\nChecking this box will enable responses to your article much like Articles on Slashdot.org.\r\n<p>\r\n\r\n\r\n<b>Filter Post</b><br>\r\nSelect the level of content filtering you wish to perform on all discussion posts.\r\n<p>\r\n\r\n<b>Who can post?</b><br>\r\nSelect the group that is allowed to post to this discussion.\r\n<p>\r\n\r\n<b>Edit Timeout</b><br>\r\nHow long should a user be able to edit their post before editing is locked to them?\r\n<p>\r\n<i>NOTE:</i> Don\'t set this limit too high. One of the great things about discussions is that they are an accurate record of who said what. If you allow editing for a long time, then a user has a chance to go back and change his/her mind a long time after the original statement was made.\r\n<p>\r\n\r\n<b>Karma Per Post</b><br>\r\nHow much karma should be given to a user when they post to this discussion?\r\n<p>\r\n\r\n<b>Who can moderate?</b><br>\r\nSelect the group that is allowed to moderate this discussion.\r\n<p>\r\n\r\n<b>Moderation Type?</b><br>\r\nYou can select what type of moderation you\'d like for your users. <i>After-the-fact</i> means that when a user posts a message it is displayed publically right away. <i>Pre-emptive</i> means that a moderator must preview and approve users posts before allowing them to be publically visible. Alerts for new posts will automatically show up in the moderator\'s WebGUI Inbox.\r\n<p>\r\n<i>NOTE:</i> In both types of moderation the moderator can always edit or delete the messages posted by your users.\r\n<p>\r\n\r\n<b>Add edit stamp to posts?</b><br>\r\nDo you wish to "stamp" all edits so that you can track who edited a post and when?\r\n<p>', 1050146714);
delete from international where languageId=1 and namespace='Article' and internationalId=73;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (73,1,'Article','The following template variables are available for article templates.\r\n<p/>\r\n\r\n<b>attachment.box</b><br/>\r\nOutputs a standard WebGUI attachment box including icon, filename, and attachment indicator.\r\n<p/>\r\n\r\n<b>attachment.icon</b><br/>\r\nThe URL to the icon image for this attachment type.\r\n<p/>\r\n\r\n<b>attachment.name</b><br/>\r\nThe filename for this attachment.\r\n<p/>\r\n\r\n<b>attachment.url</b><br/>\r\nThe URL to download this attachment.\r\n<p/>\r\n\r\n<b>image.thumbnail</b><br/>\r\nThe URL to the thumbnail for the attached image.\r\n<p/>\r\n\r\n<b>image.url</b><br/>\r\nThe URL to the attached image.\r\n<p/>\r\n\r\n<b>post.label</b><br/>\r\nThe translated label to add a comment to this article.\r\n<p/>\r\n\r\n\r\n<b>post.URL</b><br/>\r\nThe URL to add a comment to this article.\r\n<p/>\r\n\r\n<b>replies.count</b><br/>\r\nThe number of comments attached to this article.\r\n<p/>\r\n\r\n<b>replies.label</b><br/>\r\nThe translated text indicating that you can view the replies.\r\n<p/>\r\n\r\n<b>replies.url</b><br/>\r\nThe URL to view the replies to this article.\r\n<p/>\r\n\r\n\r\n<b>firstPage</b><br/>\r\nA link to the first page in the paginator.\r\n<p/>\r\n\r\n<b>lastPage</b><br/>\r\nA link to the last page in the paginator.\r\n<p/>\r\n\r\n<b>nextPage</b><br/>\r\nA link to the next page forward in the paginator.\r\n<p/>\r\n\r\n<b>previousPage</b><br/>\r\nA link to the next page backward in the paginator.\r\n<p/>\r\n\r\n<b>pageList</b><br/>\r\nA list of links to all the pages in the paginator.\r\n<p/>\r\n\r\n<b>multiplePages</b><br/>\r\nA conditional indicating whether there is more than one page in the paginator.\r\n<p/>\r\n\r\n<b>isFirstPage</b><br/>\r\nA conditional indicating whether the visitor is viewing the first page.\r\n<p/>\r\n\r\n<b>isLastPage</b><br/>\r\nA conditional indicating whether the visitor is viewing the last page.\r\n<p/>\r\n\r\n', 1050146621);





