///////////////////////////////////
//////////// Preamble /////////////
///////////////////////////////////

// Output settings
settings.outformat = "png";
settings.prc = false;
settings.render = 16;

// Font settings
defaultpen(fontsize(10pt));
// settings.tex="xelatex";
// texpreamble("\usepackage{fontspec}\setmainfont{Noto Serif CJK KR}");
texpreamble("\usepackage{bm}\renewcommand{\vec}[1]{\bm{\mathrm{#1}}}");

// Use 3D graphs
import graph3;

// Figure settings
size(14cm, 0);
currentprojection = orthographic(-1, 6, 5);

///////////////////////////////////
/////////// Mathematics ///////////
///////////////////////////////////

// Global constant representing an infinitestimal.
real epsilon = .0001;

// Returns the derivative f'(t) of a parametrized function f: R -> R^3.
triple derivative(triple f(real), real t, real dx=epsilon)
{
    return (f(t + dx) - f(t - dx)) / 2dx;
}

// Returns a vector starting from `start` with a direction `direction`.
path3 pos(triple start, triple direction)
{
    return shift(start) * (O -- direction);
}

// Base vector
triple base(real t)
{
    return (3cos(t / sqrt(10)), 3sin(t / sqrt(10)), t / sqrt(10));
}

// Tangent vector
triple tangent(real t)
{
    return unit(derivative(base, t));
}

// Normal vector
triple normal(real t)
{
    return unit(derivative(tangent, t));
}

// Binormal vector
triple binormal(real t)
{
    return cross(tangent(t), normal(t));
}

// N_theta vector
triple normal(real t, real theta)
{
    return cos(theta) * normal(t) + sin(theta) * binormal(t);
}

// O_theta (center of a circle)
triple center(real t, real theta)
{
    return base(t) + normal(t, theta);
}

// The rolling circle
path3 cyCircle(real t, real theta, real radius=1)
{
    triple n = cross(tangent(t), normal(t, theta));
    return circle(center(t, theta), radius, normal=n);
}

// Parametrized cycloidal surface
triple paramCycloid(real t, real theta)
{
    return center(t, theta) - sin(t) * tangent(t) - cos(t) * normal(t, theta);
}

triple paramCycloid(pair z)
{
    return paramCycloid(xpart(z), ypart(z));
}

triple principalCycloid(real t)
{
    return paramCycloid(t, 0);
}

// Parametrized trochoidal surface
triple paramTrochoid(real t, real theta, real d)
{
    return (1 - d) * center(t, theta) + d * paramCycloid(t, theta);
}

triple paramTrochoid(pair z, real d)
{
    return paramTrochoid(xpart(z), ypart(z), d);
}

triple cameraDirection(triple pt, projection p=currentprojection)
{
    if (p.infinity) {
        return unit(p.camera);
    } else {
        return unit(p.camera - pt);
    }
}

triple towardCamera(triple pt, real distance=1, projection p=currentprojection)
{
  return pt + distance * cameraDirection(pt, p);
}

///////////////////////////////////
////////// Start drawing //////////
///////////////////////////////////
// t range
real tMin = 0;
real tMax = 2pi;

// real lateralAngle = pi / 8;
real lateralAngle(real t)
{
    return pi / 4;
    // return 2t;
}

pen extraThin = linewidth(.2pt);
pen thin = linewidth(.4pt);
pen thick = linewidth(1pt);
pen extraThick = linewidth(2pt);

path3 baseCurve = graph(base, tMin, tMax, operator ..);
draw(
    baseCurve,
    thin,
    arrow=Arrow3(TeXHead2)
);

real t = (2tMin + tMax) / 3;
// Current point on the base curve
triple curr = base(t);
dot(curr, extraThick, L=Label("$\vec r(t)$", align=SW));

// Start circle
// triple startCenter = center(tMin, lateralAngle(tMin));
// path3 startCircle = cyCircle(tMin, lateralAngle(tMin));
// dot(base(tMin), thick);
// dot(startCenter, thick);
// draw(startCircle, blue + thin);
// draw(surface(startCircle), blue + opacity(.1), light=nolight);

// triple startInter = paramTrochoid(tMin, lateralAngle(tMin), .5);
// dot(startInter, extraThick);
// draw(startInter -- base(tMin) -- startCenter, thin);

// End circle
// triple endCenter = center(tMax, 0);
// path3 endCircle = cyCircle(tMax, 0);
// dot(base(tMax), thick);
// dot(endCenter, thick);
// draw(endCircle, red + thin);
// draw(surface(endCircle), red + opacity(.1), light=nolight);
//
// triple endInter = paramTrochoid(tMax, 0, .5);
// triple endInter2 = paramTrochoid(tMax, lateralAngle(tMax), .5);
// dot(endInter, extraThick);
// dot(endInter2, extraThick);
// draw(paramTrochoid(tMax, lateralAngle(tMax), .5) -- base(tMax) -- endCenter, thin);

// The TNB frame
draw(
    pos(curr, tangent(t)),
    red + thin,
    arrow=Arrow3(),
    L=Label("$\vec T$", position=EndPoint, align=SW)
);
draw(
    pos(curr, normal(t)),
    green + thin,
    arrow=Arrow3(),
    L=Label("$\vec N$", position=EndPoint, align=NE)
);
draw(
    pos(curr, binormal(t)),
    blue + thin,
    arrow=Arrow3(),
    L=Label("$\vec B$", position=EndPoint, align=W)
);

// main red circle (principal)
triple redCenter = center(t, 0);
// path3 redCircle = cyCircle(t, 0);
// dot(redCenter, thick);
// draw(redCircle, red + thin);
// draw(surface(redCircle), red + opacity(.1), light=nolight);
//
// triple redInter = paramTrochoid(t, 0, .5);
// dot(redInter, extraThick);
// draw(redCenter -- redInter, thin, arrow=Arrow3());

// path3 redRollDir =
//     arc(curr, curr + (redCenter - curr) / 4, curr + (blueCenter  - curr) / 4);

// main blue circle
triple blueCenter = center(t, lateralAngle(t));
path3 blueCircle = cyCircle(t, lateralAngle(t));
dot(blueCenter, thick, L=Label("$O_\theta$", align=.3N + E));
draw(blueCircle, red + thin);
draw(surface(blueCircle), red + opacity(.1), light=nolight);

triple blueInter1 = paramTrochoid(t, lateralAngle(t), .5);
dot(blueInter1, extraThick, L=Label("$T_\theta(t)$", align=NE));
triple blueInter2 = paramCycloid(t, lateralAngle(t));
dot(blueInter2, extraThick, L=Label("$C_\theta(t)$", align=.5NW));
draw(blueCenter -- blueInter2, thin);
// draw(
//     blueCenter -- blueInter2,
//     invisible,
//     L=Label("$d$", black, align=E, position=MidPoint / 2)
// );

draw(
    curr -- blueInter1,
    thin,
    L=Label("$(v)$", fontsize(8), position=MidPoint / 2, align=NW)
);
draw(
    curr -- blueInter1,
    invisible,
    L=Label(
        "$(1 - v)$",
        black + fontsize(8),
        position=(MidPoint + EndPoint) / 2,
        align=W
    )
);
dot((curr + blueInter1) / 2, extraThick);
label(
    Label("$Y(\theta, t, v)$"),
    position=towardCamera((curr + blueInter1) / 2),
    align=E
);

draw(
    curr -- blueCenter,
    green + thin,
    arrow=Arrow3()
    // arrow=Arrow3(emissive(darkgray)),
    // L=Label("$\vec N_\theta$", position=MidPoint, align=E)
);
//
// draw(
//     blueCenter -- pos(blueCenter, tangent(t)),
//     red + thin,
//     arrow=Arrow3(),
//     L=Label("$\vec T$", position=EndPoint, align=E)
// );

// angle symbol
path3 angleArc =
    arc(curr, curr + (redCenter - curr) / 4, curr + (blueCenter  - curr) / 4);
draw(angleArc, thin);
label(
    "$\theta$",
    align=(NE + E) / 2,
    // position=towardCamera(midpoint(angleArc))
    position=midpoint(angleArc)
);

// rolling angle
triple rollingAngle(real t, real theta, real d, real phi)
{
    return center(t, theta)
        + d * cos(phi) * tangent(t) + d * sin(phi) * normal(t, theta);
}
var rollingAngleArc = graph(
    new triple (real theta) {
        return rollingAngle(t, lateralAngle(t), 1.2, theta);
    },
    pi / 3,
    pi / 4
);
draw(
    rollingAngleArc,
    thin,
    arrow=Arrow3(TeXHead2),
    align=W
);

// var rollingAngleArc = graph(
//     new triple (real theta) {
//         return rollingAngle(t, lateralAngle(t), .15, theta);
//     },
//     -pi / 2,
//     -pi / 2 - t
// );
// draw(
//     rollingAngleArc,
//     thin,
//     L=Label("$-t$"),
//     arrow=Arrow3(TeXHead2),
//     align=W
// );

// var rollingAngleArc2 = graph(
//     new triple (real theta) {
//         return rollingAngle(t, lateralAngle(t), .15, theta);
//     },
//     0,
//     -pi / 2
// );
// draw(
//     rollingAngleArc2,
//     thin,
//     L=Label("$-\frac\pi 2$"),
//     arrow=Arrow3(TeXHead2),
//     align=S + .3E
// );
//


// Draw the trochoidal surface
nmesh = 12;
var trochoidalSurface = surface(
    new triple (pair z) { return paramTrochoid(xpart(z), ypart(z), 0.5); },
    // (tMin, -pi / 10), (tMax, lateralAngle(t) + pi / 10), Spline
    (tMin, 0), (tMax, 2pi), Spline
);
var surfacepen = material(
    white+opacity(.1),
    emissivepen=gray(.5)
);
var meshpen = gray + opacity(.1) + extraThin;
draw(
    trochoidalSurface,
    surfacepen=surfacepen,
    meshpen=meshpen
);

// Draw a trochoids
for (real ang : new real[] {0, lateralAngle(t)}) {
    path3 trochoidalCurve = graph(
        new triple (real t) { return paramTrochoid(t, lateralAngle(t), 0.5); },
        tMin, tMax, operator ..
    );

    if (ang == 0) {
        // draw(trochoidalCurve, red + thick);
    } else {
        draw(trochoidalCurve, red + thick);
    }
}

// shipout(scale(4.0) * currentpicture.fit());
