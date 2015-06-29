/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is dom4 code.
 *
 * The Initial Developer of the Original Code is
 * Disruptive Innovations SAS
 * Portions created by the Initial Developer are Copyright (C) 2014
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Daniel Glazman <daniel.glazman@disruptive-innovations.com>
 *   Franco Ponticelli <franco.ponticelli@gmail.com>
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either of the GNU General Public License Version 2 or later (the "GPL"),
 * or the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 *
 * ***** END LICENSE BLOCK ***** */

import dom4.Document;
import dom4.DOMParser;
import dom4.utils.BasicContentSink;
import dom4.utils.Serializer;

import utest.Assert;
import utest.Runner;
import utest.ui.Report;

class Test {
  public function new() {}

  var sourceXml = "<!DOCTYPE foobar><foobar xmlns='http://example.org/example.org/example.org/example.org/example.org/example.org/' xmlns:html='http://www.w3.org/1999/xhtml'>  a&lt;éaaaa  <html:p>   foobar<span>blag</span>  sdsdsdf</html:p>  <myelem label='fo\"o'/></foobar>  ";
  var document : Document;

  public function setup() {
    var contentSink = new BasicContentSink();
    var parser      = new DOMParser(contentSink);
    document = parser.parseFromString(sourceXml, "text/xml");
  }

  public function testBasics() {
    Assert.equals('foobar', document.documentElement.nodeName);
    Assert.equals(4, document.documentElement.childNodes.length);
    Assert.equals(2, document.documentElement.children.length);
  }

  public function testSerializer() {
    var s = new Serializer();
    s.enableIndentation();
    s.enableWrapping(72);
    Assert.equals('<!DOCTYPE foobar>
<foobar xmlns="http://example.org/example.org/example.org/example.org/example.org/example.org/"
         xmlns:html="http://www.w3.org/1999/xhtml">
  a&lt;éaaaa
  <html:p>
    foobar
    <span>blag</span>
    sdsdsdf
  </html:p>
  <myelem label="fo&quot;o" />
</foobar>', s.serializeToString(document));
  }

  static function main() : Void {
    var runner = new Runner();

    runner.addCase(new Test());
    Report.create(runner);
    runner.run();
  }
}
