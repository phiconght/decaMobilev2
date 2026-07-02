/// Luu/mo file PDF de thi theo nen tang:
/// - io (Android/iOS/desktop): ghi file tam + share sheet.
/// - web: tai xuong truc tiep (anchor download).
export 'exam_pdf_saver_io.dart'
    if (dart.library.js_interop) 'exam_pdf_saver_web.dart';
