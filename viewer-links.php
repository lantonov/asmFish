<?php

/*
 *  pgn4web javascript chessboard
 *  copyright (C) 2009-2014 Paolo Casaschi
 *  see README file and http://pgn4web.casaschi.net
 *  for credits, license and more details
 */

error_reporting(E_ALL | E_STRICT);

$targetUrl = get_param("targetUrl", "tu", "");
$linkFilterDefault = ".+.pgn$";
$linkFilter = get_param("linkFilter", "lf", $linkFilterDefault);
$frameDepthDefault = 0;
$frameDepth = get_param("frameDepth", "fd", $frameDepthDefault);
$viewerUrlDefault = "viewer.php?pd=";
$viewerUrl = get_param("viewerUrl", "vu", $viewerUrlDefault);
$doubleEncodeLink = get_param("doubleEncodeLink", "del", "false");
$doubleEncodeLink = (($doubleEncodeLink == "true") || ($doubleEncodeLink == "t"));
$reverseSort = get_param("reverseSort", "rs", "false");
$reverseSort = (($reverseSort == "true") || ($reverseSort == "t"));
$headlessPage = get_param("headlessPage", "hp", "false");
$headlessPage = (($headlessPage == "true") || ($headlessPage == "t"));
$help = get_param("help", "h", "false");
$help = (($help == "true") || ($help == "t"));
if ((! is_numeric($frameDepth)) || ($frameDepth < 0) || ($frameDepth > 5)) { $frameDepth = $frameDepthDefault; }
$actualFrameDepth = 0;
$urls = array();
get_links($targetUrl, $frameDepth);
print_links();

function get_links($targetUrl, $depth) {
    global $urls, $linkFilter, $frameDepth, $actualFrameDepth;

    if (! $targetUrl) { return; }

    if ($frameDepth - $depth > $actualFrameDepth) { $actualFrameDepth = $frameDepth - $depth; }

    $html = file_get_contents($targetUrl);
    $dom = new DOMDocument();
    @$dom->loadHTML($html);
    $xpath = new DOMXPath($dom);

    $bases = $xpath->evaluate("/html/head//base");
    if ($bases->length > 0) {
        $baseItem = $bases->item($bases->length - 1);
        $base = $baseItem->getAttribute('href');
    } else {
        $base = $targetUrl;
    }

    if ($depth > 0) {
        $frames = $xpath->evaluate("/html/body//iframe");
        for ($i = 0; $i < $frames->length; $i++) {
            $frame = $frames->item($i);
            $url = make_absolute($frame->getAttribute('src'), $base);
            if ($url != $targetUrl) { get_links($url, $depth -1); }
        }
        $frames = $xpath->evaluate("/html/body//frame");
        for ($i = 0; $i < $frames->length; $i++) {
            $frame = $frames->item($i);
            $url = make_absolute($frame->getAttribute('src'), $base);
            if ($url != $targetUrl) { get_links($url, $depth -1); }
        }
    }

    $hrefs = $xpath->evaluate("/html/body//a");
    for ($i = 0; $i < $hrefs->length; $i++) {
        $href = $hrefs->item($i);
        $url = $href->getAttribute('href');
        $absolute = make_absolute($url, $base);
        if (preg_match("@".$linkFilter."@i", parse_url($absolute, PHP_URL_PATH))) {
            array_push($urls, $absolute);
        }
    }
}

function print_links() {
    global $urls, $reverseSort, $targetUrl, $linkFilter, $frameDepth, $viewerUrl, $doubleEncodeLink, $headlessPage, $help, $actualFrameDepth;

    $labelColor = "lightgray";

    $urls = array_unique($urls);
    if ($reverseSort) { rsort($urls); }
    else { sort($urls); }

    print("<!DOCTYPE HTML>" . "\n" . "<html>" . "\n" . "<head>" . "\n");

    if (($numUrls = count($urls)) == 1) { print "<title>1 link</title>" . "\n"; }
    else { print "<title>$numUrls links</title>" . "\n"; }

    print "<link rel='icon' sizes='16x16' href='pawn.ico' />" . "\n";
    print "<style tyle='text/css'> body { font-family: sans-serif; padding: 1.75em; line-height: 1.5em; } a { color: black; text-decoration: none; } ol { color: $labelColor; } </style>" . "\n";
    print "<script type='text/javascript'> var viewerWin; </script>" . "\n";

    print("</head>" . "\n" . "<body>" . "\n");

    if ($help) {
        print("<pre>" . "\n");
        print("targetUrl = target url to scan for links" . "\n");
        print("linkFilter = filter for selecting links" . "\n");
        print("frameDepth = maximum recursive depth to scan frames" . "\n");
        print("viewerUrl = viewer url to open links" . "\n");
        print("doubleEncodeLink = true|false" . "\n");
        print("reverseSort = true|false" . "\n");
        print("headlessPage = true|false" . "\n");
        print("help = true" . "\n");
        print("\n");
        print("</pre>" . "\n");
    }

    if (!$headlessPage) {
        print "<span style='color:$labelColor'>targetUrl</span> &nbsp; &nbsp; <a href='" . $targetUrl . "' target='_blank'>" . $targetUrl . "</a><br />" . "\n";
        print "<span style='color:$labelColor'>linkFilter</span> &nbsp; &nbsp; " . $linkFilter . "<br />" . "\n";
        if ($frameDepth > 0) { print "frameDepth: &nbsp; &nbsp; <b>" . $frameDepth . "</b> &nbsp; &nbsp; <span style='opacity: 0.2;'>" . $actualFrameDepth . "</span><br />" . "\n"; }
        print("<div>&nbsp;</div>" . "\n");
    }
    if ($numUrls > 0) {
        print("<ol>" . "\n");
        for ($i = 0; $i < count($urls); $i++) {
            print("<li>");
            print("<a href='javascript:void(0);' onclick='if (event.shiftKey) { location.href = \"$urls[$i]\"; } else { if (viewerWin && !viewerWin.closed) { viewerWin.close(); } viewerWin = window.open(\"" . ($viewerUrl . ($doubleEncodeLink ? rawurlencode(rawurlencode($urls[$i])) : rawurlencode($urls[$i]))) . "\", \"pgn4web_link_viewer\"); viewerWin.focus(); } this.blur(); return false;'>");
            print($urls[$i] . "</a>" . "</li>" . "\n");
        }
        print "</ol>" . "\n";
    } else {
        print("<i>no links found</i>" . "\n");
    }

    print("</body>" . "\n" . "</html>");
}

function get_param($param, $shortParam, $default) {
  if (isset($_REQUEST[$param])) { return $_REQUEST[$param]; }
  if (isset($_REQUEST[$shortParam])) { return $_REQUEST[$shortParam]; }
  return $default;
}

function make_absolute($url, $base) {

    // Return base if no url
    if( ! $url) return $base;

    // Return if already absolute URL
    if(parse_url($url, PHP_URL_SCHEME) != '') return $url;

    // Urls only containing query or anchor
    if($url[0] == '#' || $url[0] == '?') return $base.$url;

    // Parse base URL and convert to local variables: $scheme, $host, $path
    extract(parse_url($base));

    // If no path, use /
    if( ! isset($path)) $path = '/';

    // Remove non-directory element from path
    $path = preg_replace('#/[^/]*$#', '', $path);

    // Destroy path if relative url points to root
    if($url[0] == '/') $path = '';

    // Dirty absolute URL
    $abs = "$host$path/$url";

    // Replace '//' or '/./' or '/foo/../' with '/'
    $re = array('#(/\.?/)#', '#/(?!\.\.)[^/]+/\.\./#');
    for($n = 1; $n > 0; $abs = preg_replace($re, '/', $abs, -1, $n)) {}

    // Absolute URL is ready!
    return $scheme.'://'.$abs;
}

?>
