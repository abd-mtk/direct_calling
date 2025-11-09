// Web implementation
import 'dart:html' as html;

bool makeCallWeb(String phoneNumber) {
  try {
    final anchor = html.AnchorElement(href: 'tel:$phoneNumber')
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    return true;
  } catch (e) {
    // If web implementation fails, return false gracefully
    return false;
  }
}

