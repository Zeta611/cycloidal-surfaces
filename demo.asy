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

// Use 3D graphs
import graph3;

// Figure settings
size(7cm, 0);
currentprojection = orthographic(3, 4, 5);

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

// u-frame vector
triple uFrame(real t, real u)
{
    return cos(u) * normal(t) + sin(u) * binormal(t);
}

// u-circle center
triple uCenter(real t, real u)
{
    return base(t) + uFrame(t, u);
}

// u-circle
path3 uCircle(real t, real u, real radius=1)
{
    triple n = cross(tangent(t), uFrame(t, u));
    return circle(uCenter(t, u), radius, normal=n);
}

// Parametrized cycloidal surface
triple paramCycloid(real t, real u)
{
    assert(0 <= u && u <= 2pi, "u should be in range [0, 2pi]");
    return uCenter(t, u) - sin(t) * tangent(t) - cos(t) * uFrame(t, u);
}

triple paramCycloid(pair z)
{
    return paramCycloid(xpart(z), ypart(z));
}

triple principalCycloid(real t)
{
    return paramCycloid(t, 0);
}

///////////////////////////////////
////////// Start drawing //////////
///////////////////////////////////
// Axes
// draw(O -- 5X ^^ O -- 5Y ^^ O -- 5Z);  // One liner
draw(O -- 6X, L=Label("$x$", position=EndPoint));
draw(O -- 6Y, L=Label("$y$", position=EndPoint));
draw(O -- 9Z, L=Label("$z$", position=EndPoint));

// t range
real tMin = 0;
real tMax = 2pi * sqrt(10);

// Draw curves
path3 baseCurve = graph(base, tMin, tMax, operator ..);
draw(baseCurve, gray+linewidth(.4pt));

// path3 centerCurve = graph(
//     new triple (real t) { return uCenter(t, 0); },
//     tMin,
//     tMax,
//     operator ..
// );
// draw(centerCurve, lightgray + linewidth(.2pt));

path3 principalCycloidCurve = graph(principalCycloid, tMin, tMax, operator ..);
draw(principalCycloidCurve, red);

// Draw TNB frames
int steps = 5;
for (int i = 0; i < steps; ++i) {
    real t = tMin + (tMax - tMin) / steps * i;
    // Current point on the base curve
    triple curr = base(t);
    dot(curr);
    draw(pos(curr, tangent(t)), red + linewidth(.4pt), arrow=Arrow3());
    draw(pos(curr, normal(t)), green + linewidth(.4pt), arrow=Arrow3());
    draw(pos(curr, binormal(t)), blue + linewidth(.4pt), arrow=Arrow3());
    draw(uCircle(t, 0), red + linewidth(.4pt));
}

// Draw the cycloidal surface
nmesh = 90;
var cycloidalSurface = surface(paramCycloid, (tMin, 0), (tMax, 2pi), Spline);
var surfacepen = material(
    mediumred+opacity(.5),
    emissivepen=gray(.5),
    shininess=.62
);
draw(cycloidalSurface, surfacepen=surfacepen);

// shipout(scale(4.0) * currentpicture.fit());
