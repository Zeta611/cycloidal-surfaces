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
size(8cm, 0);
currentprojection = orthographic(-2, 6, 11);

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
real tMin = -pi / 4;
real tMax = 2pi + pi / 4;

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

path3 baseCurve = graph(base, tMin, 2pi + pi / 5, operator ..);
draw(
    baseCurve,
    thin,
    L=Label("$\vec r(t)$", position=EndPoint),
    arrow=Arrow3(TeXHead2)
);

real t = 2pi / 3;//(tMin + 2tMax) / 3;
// Current point on the base curve
// triple curr = base(t);
// dot(curr, thick);

// Start circle
// triple startCenter = center(0, lateralAngle(t));
// path3 startCircle = cyCircle(0, lateralAngle(t));
// dot(base(0), thick);
// dot(startCenter, thick);
// draw(startCircle, red + thin);
// draw(surface(startCircle), red + opacity(.1), light=nolight);
//
// triple startInter = paramCycloid(0, lateralAngle(t));
// dot(startInter, extraThick);
// draw(startInter -- base(0) -- startCenter, thin);

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
// draw(
//     pos(curr, tangent(t)),
//     red + thin,
//     arrow=Arrow3(),
//     L=Label("$\vec T$", position=EndPoint, align=SW)
// );
// draw(
//     pos(curr, normal(t)),
//     green + thin,
//     arrow=Arrow3(),
//     L=Label("$\vec N$", position=EndPoint, align=SE)
// );
// draw(
//     pos(curr, binormal(t)),
//     blue + thin,
//     arrow=Arrow3(),
//     L=Label("$\vec B$", position=EndPoint, align=W)
// );

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

real[] angles = {0, pi, 4pi / 3};
string[] labels = {"0", "$\frac{\pi}{3}$", "$\frac{2\pi}{3}$", "$\pi$",
    "$\frac{4\pi}{3}$", "$\frac{5\pi}{3}$"};
for (real angle = 0; angle < 2pi; angle += pi / 3) {
    path3 trochoidalCurve = graph(
        new triple (real t) { return paramTrochoid(t, angle, .5); },
        0, 2pi, operator ..
    );
    if (angle == pi / 3) {
        draw(trochoidalCurve, blue + thick);
        label(
            "$\theta \equiv \frac\pi 3$",
            align=S + 5E,
            position=towardCamera(paramTrochoid(pi, angle, .5), distance=5)
        );
    } else if (angle == 2pi / 3) {
        draw(trochoidalCurve, blue + thick);
        label(
            "$\theta \equiv \frac{2\pi}{3}$",
            align=S + 5E,
            position=towardCamera(paramTrochoid(pi, angle, .5), distance=5)
        );
    } else if (angle == pi) {
        draw(trochoidalCurve, blue + thick);
        label(
            "$\theta \equiv \pi$",
            align=S + 5E,
            position=towardCamera(paramTrochoid(pi, angle, .5), distance=5)
        );
    } else {
        draw(trochoidalCurve, blue + thick);
    }
}
path3 trochoidalCurve = graph(
    new triple (real t) { return paramTrochoid(t, t, .5); },
    0, 2pi, operator ..
);
draw(trochoidalCurve, red + thick, L=Label("$\theta(t) = t$"));

// Draw the trochoidal surface
nmesh = 24;
var trochoidalSurface = surface(
    new triple (pair z) { return paramTrochoid(xpart(z), ypart(z), .5); },
    (0, 0), (2pi, 2pi), Spline
);
var surfacepen = material(
    white+opacity(.8),
    emissivepen=gray(.5)
);
var meshpen = black + linewidth(.1pt);
draw(trochoidalSurface, surfacepen=surfacepen, meshpen=meshpen);

// path3 startLid = graph(
//     new triple (real theta) { return paramTrochoid(0, theta, .5); },
//     0, 2pi
// );
// draw(surface(startLid -- cycle), opacity(.4));
//
// path3 endLid = graph(
//     new triple (real theta) { return paramTrochoid(2pi, theta, .5); },
//     0, 2pi
// );
// draw(surface(endLid -- cycle), opacity(.4));

// shipout(scale(4.0) * currentpicture.fit());
