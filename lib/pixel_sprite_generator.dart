/**
 * Pixel Sprite Generator v0.0.1
 *
 * This is a Dart port of the JavaScript version of David Bollinger's pixelrobots and
 * pixelspaceships algorithm.
 *
 * More info:
 * http://www.davebollinger.com/works/pixelrobots/
 * http://www.davebollinger.com/works/pixelspaceships/
 *
 * Archived website (links above are down):
 * http://web.archive.org/web/20080228054405/http://www.davebollinger.com/works/pixelrobots/
 * http://web.archive.org/web/20080228054410/http://www.davebollinger.com/works/pixelspaceships/
 *
 */

library pixel_sprite_generator;
import 'dart:html';
import 'dart:math' as Math;

/**
 *   The Mask class defines a 2D template form which sprites can be generated.
 *
 *   @class Mask
 *   @constructor
 *   @param {data} Integer array describing which parts of the sprite should be
 *   empty, body, and border. The mask only defines a semi-ridgid stucture
 *   which might not strictly be followed based on randomly generated numbers.
 *
 *      -1 = Always border (black)
 *       0 = Empty
 *       1 = Randomly chosen Empty/Body
 *       2 = Randomly chosen Border/Body
 *
 *   @param {width} Width of the mask data array
 *   @param {height} Height of the mask data array
 *   @param {mirrorX} A boolean describing whether the mask should be mirrored on the x axis
 *   @param {mirrorY} A boolean describing whether the mask should be mirrored on the y axis
 */
class Mask {
  List<num> data;
  num width, height;
  bool mirrorX, mirrorY;
  Mask(this.data, this.width, this.height, this.mirrorX, this.mirrorY);
}


/**
*   The Sprite class makes use of a Mask instance to generate a 2D sprite on a
*   HTML canvas.
*
*   @class Sprite
*   @param {mask}
*   @constructor
*/
class Sprite {
  Mask mask;
  num width, height;
  List<num> data;
  bool isColored;
  CanvasElement canvas;
  Sprite(this.mask, this.isColored) {
    width = mask.width * (mask.mirrorX ? 2 : 1);
    height = mask.height * (mask.mirrorY ? 2 : 1);
    data = new List<num>(this.width * this.height);
    
    init();
  }
  
  /**
  *   The init method calls all functions required to generate the sprite.
  *
  *   @method init
  *   @returns {undefined}
  */
  void init() {
    initCanvas();
    initContext();
    initData();

    applyMask();
    generateRandomSample();

    if (mask.mirrorX) {
      mirrorX();
    }

    if (mask.mirrorY) {
      mirrorY();
    }

    generateEdges();
    renderPixelData();
  }

  /**
    *   The initCanvas method creates a HTML canvas element for internal use.
    *
    *   (note: the canvas element is not added to the DOM)
    *
    *   @method initCanvas
    *   @returns {undefined}
    */
  void initCanvas() {
    canvas = document.createElement('canvas');
     
    canvas.width  = this.width;
    canvas.height = this.height;  
  }
  
  /**
  *   The initContext method requests a CanvasRenderingContext2D from the
  *   internal canvas object.
  *
  *   @method 
  *   @returns {undefined}
  */
  CanvasRenderingContext2D ctx;
  ImageData pixels;
  void initContext() {
    ctx    = canvas.getContext('2d');
    pixels = ctx.createImageData(this.width, this.height);
  }
  
  /**
  *   The getData method returns the sprite template data at location (x, y)
  *
  *      -1 = Always border (black)
  *       0 = Empty
  *       1 = Randomly chosen Empty/Body
  *       2 = Randomly chosen Border/Body
  *
  *   @method getData
  *   @param {x}
  *   @param {y}
  *   @returns {undefined}
  */
  num getData(num x, num y) {
    return data[y * width + x];
  }
  
  /**
  *   The setData method sets the sprite template data at location (x, y)
  *
  *      -1 = Always border (black)
  *       0 = Empty
  *       1 = Randomly chosen Empty/Body
  *       2 = Randomly chosen Border/Body
  *
  *   @method setData
  *   @param {x}
  *   @param {y}
  *   @param {value}
  *   @returns {undefined}
  */
  void setData(num x, num y, num value) {
    data[y * width + x] = value;
  }
  
  /**
  *   The initData method initializes the sprite data to completely solid.
  *
  *   @method initData
  *   @returns {undefined}
  */
  void initData() {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        setData(x, y, -1);
      }
    }
  }
  
  /**
  *   The mirrorX method mirrors the template data horizontally.
  *
  *   @method mirrorX
  *   @returns {undefined}
  */
  void mirrorX() {
    var w = (width/2).floor();
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < w; x++) {
        setData(width - x - 1, y, getData(x, y));
      }
    }
  }
  
  /**
  *   The mirrorY method mirrors the template data vertically.
  *
  *   @method 
  *   @returns {undefined}
  */
  void mirrorY() {
    var h = (height/2).floor();
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < width; x++) {
        setData(x, height - y - 1, getData(x, y));
      }
    }
  }
  
  /**
  *   The applyMask method copies the mask data into the template data array at
  *   location (0, 0).
  *
  *   (note: the mask may be smaller than the template data array)
  *
  *   @method applyMask
  *   @returns {undefined}
  */
  void applyMask() {
    for (int y = 0; y < mask.height; y++) {
      for (int x = 0; x < mask.width; x++) {
        setData(x, y, mask.data[y * mask.width + x]);
      }
    }
  }
  
  /**
  *   Apply a random sample to the sprite template.
  *
  *   If the template contains a 1 (internal body part) at location (x, y), then
  *   there is a 50% chance it will be turned empty. If there is a 2, then there
  *   is a 50% chance it will be turned into a body or border.
  *
  *   (feel free to play with this logic for interesting results)
  *
  *   @method generateRandomSample
  *   @returns {undefined}
  */
  void generateRandomSample() {
    var rand = new Math.Random();
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        var val = getData(x, y);
        if (val == 1) {
          val = val * rand.nextDouble().round();
        } else if (val == 2) {
          if (rand.nextBool()) {
            val = 1;
          } else {
            val = -1;
          }
        } 

        setData(x, y, val);
      }
    }
  }
  
  /**
  *   This method applies edges to any template location that is positive in
  *   value and is surrounded by empty (0) pixels.
  *
  *   @method generateEdges
  *   @returns {undefined}
  */
  void generateEdges() {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (getData(x, y) > 0) {
          if (y - 1 >= 0 && getData(x, y - 1) == 0) {
            setData(x, y - 1, -1);
          }
          if (y + 1 < height && getData(x, y + 1) == 0) {
            setData(x, y+1, -1);
          }
          if (x - 1 >= 0 && getData(x - 1, y) == 0) {
            setData(x-1, y, -1);
          }
          if (x + 1 < width && getData(x + 1, y) == 0) {
            setData(x + 1, y, -1);
          }
        }
      }
    }
  }
  
  /**
  *   This method renders out the template data to a HTML canvas to finally
  *   create the sprite.
  *
  *   (note: only template locations with the values of -1 (border) are rendered)
  *
  *   @method renderPixelData
  *   @returns {undefined}
  */
  void renderPixelData() {
    var rand = new Math.Random();
    var isVerticalGradient = rand.nextBool();
    var saturation         = rand.nextDouble() * 0.5;
    var hue                = rand.nextDouble();

    var v, ulen, vlen;
    if (isVerticalGradient) {
      ulen = height;
      vlen = width;
    } else {
      ulen = width;
      vlen = height;
    }

    for (int u = 0; u < ulen; u++) {
      // Create a non-uniform random number between 0 and 1 (lower numbers more likely)
      var isNewColor = (((rand.nextDouble() * 2 - 1) + 
                         (rand.nextDouble() * 2 - 1) +
                         (rand.nextDouble() * 2 - 1)) / 3).abs();

      // Only change the color sometimes (values above 0.8 are less likely than others)
      if (isNewColor > 0.8) {
        hue = rand.nextDouble();
      }

      for (v = 0; v < vlen; v++) {
        var val, index;
        if (isVerticalGradient) {
          val   = getData(v, u);
          index = (u * vlen + v) * 4;
        } else {
          val   = getData(u, v);
          index = (v * ulen + u) * 4;
        }

        rgbValue rgb = new rgbValue(1.0, 1.0, 1.0);

        if (val != 0) {
          if (this.isColored) {
            // Fade brightness away towards the edges
            var brightness = Math.sin((u / ulen) * Math.PI) * 0.7 + rand.nextDouble() * 0.3;

            // Get the RGB color value
            hslToRgb(hue, saturation, brightness, rgb);

            // If this is an edge, then darken the pixel
            if (val == -1) {
                rgb.r *= 0.3;
                rgb.g *= 0.3;
                rgb.b *= 0.3;
            }
          } else {
            // Not colored, simply output black
            if (val == -1) {
              rgb.r = 0.0;
              rgb.g = 0.0;
              rgb.b = 0.0;
            }
          }
        }

        pixels.data[index + 0] = (rgb.r * 255).toInt();
        pixels.data[index + 1] = (rgb.g * 255).toInt();
        pixels.data[index + 2] = (rgb.b * 255).toInt();
        pixels.data[index + 3] = 255;
      }
    }

    ctx.putImageData(pixels, 0, 0);
  }
  
  /**
  *   This method converts HSL color values to RGB color values.
  *
  *   @method hslToRgb
  *   @param {h}
  *   @param {s}
  *   @param {l}
  *   @param {result}
  *   @returns {result}
  */
  void hslToRgb(h, s, l, rgbValue result) {

      num i, f, p, q, t;
      i = (h * 6).floor();
      f = h * 6 - i;
      p = l * (1 - s);
      q = l * (1 - f * s);
      t = l * (1 - (1 - f) * s);
      
      switch (i % 6) {
          case 0: result.r = l; result.g = t; result.b = p; break;
          case 1: result.r = q; result.g = l; result.b = p; break;
          case 2: result.r = p; result.g = l; result.b = t; break;
          case 3: result.r = p; result.g = q; result.b = l; break;
          case 4: result.r = t; result.g = p; result.b = l; break;
          case 5: result.r = l; result.g = p; result.b = q; break;
      }
  }
  
  /**
  *   This method converts the template data to a string value for debugging
  *   purposes.
  *
  *   @method toString
  *   @returns {undefined}
  */
  String toString() {
    var h = height;
    var w = width;
    var x, y, output = '';
    for (y = 0; y < h; y++) {
      for (x = 0; x < w; x++) {
        var val = this.getData(x, y);
        output += val >= 0 ? ' ' + val : '' + val;
      }
      output += '\n';
    }
    return output;
  }
}

class rgbValue {
  double r, g, b;
  rgbValue(this.r, this.g, this.b);
}
