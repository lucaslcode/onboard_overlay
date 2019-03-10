import 'dart:async';
import 'package:flutter/widgets.dart';

class OnboardStep {
GlobalKey key;
String label;
ShapeBorder shape;
EdgeInsets margin;
bool tappable;
Stream proceed;
OnboardStep({
@required this.key,
this.label: "",
this.shape: const RoundedRectangleBorder(
borderRadius: BorderRadius.all(Radius.circular(8)),
),
this.margin: const EdgeInsets.all(8),
this.tappable: true,
this.proceed,
});
}

onboard(List<OnboardStep> steps, BuildContext context) {
List<OverlayEntry> overlays = [];
List.generate(steps.length, (i) => i).forEach((i) {
RenderBox box = steps[i].key.currentContext.findRenderObject();
var offset = box.localToGlobal(Offset.zero);
overlays.add(
OverlayEntry(
builder: (context) {
Widget w = OnboardOverlay(
step: steps[i],
hole: offset & box.size,
);
return steps[i].tappable
? GestureDetector(
behavior: HitTestBehavior.opaque,
onTap: () => _go(i + 1, steps, overlays, Overlay.of(context)),
child: w,
)
: w;
},
),
);
});
_go(0, steps, overlays, Overlay.of(context));
}

_go(int i, List<OnboardStep> steps, List<OverlayEntry> overlays,
OverlayState overlay) {
if (i != 0) overlays.removeAt(0).remove();
if (overlays.isNotEmpty) {
overlay.insert(overlays[0]);
StreamSubscription s;
s = steps[i].proceed?.listen((_) {
s.cancel();
_go(i + 1, steps, overlays, overlay);
});
}
}

class OnboardOverlay extends StatefulWidget {
final OnboardStep step;
final Rect _h;
OnboardOverlay({this.step, Rect hole})
: _h = step.margin.inflateRect(hole);

_OOState createState() => _OOState();
}

class _OOState extends State<OnboardOverlay>
with SingleTickerProviderStateMixin {
AnimationController _c;
RectTween _h;

initState() {
super.initState();
_h =
RectTween(begin: Rect.zero.shift(widget._h.center), end: widget._h);
_c =
AnimationController(vsync: this, duration: Duration(milliseconds: 400));
_c.forward();
_c.addListener(() => setState(() {}));
}

dispose() {
_c.dispose();
super.dispose();
}

Widget build(BuildContext context) => CustomPaint(
painter: HolePainter(
shape: widget.step.shape, hole: _h.evaluate(_c)),
foregroundPainter: LabelPainter(
label: widget.step.label,
opacity: _c.value,
hole: _h.end,
screen: MediaQuery.of(context).size,
),
);
}

class HolePainter extends CustomPainter {
final ShapeBorder shape;
final Rect hole;
HolePainter({this.shape, this.hole});

bool hitTest(Offset o) {
return !hole.contains(o);
}

paint(Canvas c, Size s) {
var cPath = Path()
..lineTo(s.width, 0)
..lineTo(s.width, s.height)
..lineTo(0, s.height)
..close();
var hPath = shape.getOuterPath(hole);
var p = Path.combine(PathOperation.difference, cPath, hPath);
c.drawPath(
p,
Paint()
..color = Color(0xaa000000)
..style = PaintingStyle.fill,
);
}

bool shouldRepaint(HolePainter old) => hole != old.hole;
}

class LabelPainter extends CustomPainter {
final String label;
final double opacity;
final Rect hole;
final Size screen;
LabelPainter({this.label, this.opacity, this.hole, this.screen});

paint(Canvas c, Size s) {
var p = TextPainter(
text: TextSpan(
text: label,
style: TextStyle(color: Color.fromRGBO(255, 255, 255, opacity))),
textDirection: TextDirection.ltr,
);
p.layout(maxWidth: s.width * 0.8);
var o = Offset(
s.width / 2 - p.size.width / 2,
hole.center.dy <= screen.height / 2
? hole.bottom + p.size.height * 1.5
: hole.top - p.size.height * 1.5,
);
p.paint(c, o);
}

bool shouldRepaint(LabelPainter old) => opacity != old.opacity;
}
