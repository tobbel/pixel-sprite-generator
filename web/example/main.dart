import 'dart:html';
import 'package:pixel_sprite_generator/pixel_sprite_generator.dart';

void main() {
  window.onLoad.listen((e) => createExample());
}

void createExample() {
  var SPRITE_SCALE = 2;
  var SPRITE_COUNT = 100;

  var spaceship = new Mask([
          0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 1, 1,
          0, 0, 0, 0, 1,-1,
          0, 0, 0, 1, 1,-1,
          0, 0, 0, 1, 1,-1,
          0, 0, 1, 1, 1,-1,
          0, 1, 1, 1, 2, 2,
          0, 1, 1, 1, 2, 2,
          0, 1, 1, 1, 2, 2,
          0, 1, 1, 1, 1,-1,
          0, 0, 0, 1, 1, 1,
          0, 0, 0, 0, 0, 0
  ], 6, 12, true, false);

  var dragon = new Mask([
          0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,1,1,1,1,0,0,0,0,
          0,0,0,1,1,2,2,1,1,0,0,0,
          0,0,1,1,1,2,2,1,1,1,0,0,
          0,0,0,0,1,1,1,1,1,1,1,0,
          0,0,0,0,0,0,1,1,1,1,1,0,
          0,0,0,0,0,0,1,1,1,1,1,0,
          0,0,0,0,1,1,1,1,1,1,1,0,
          0,0,1,1,1,1,1,1,1,1,0,0,
          0,0,0,1,1,1,1,1,1,0,0,0,
          0,0,0,0,1,1,1,1,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0
  ], 12, 12, false, false); 
          
  var robot = new Mask([
          0, 0, 0, 0,
          0, 1, 1, 1,
          0, 1, 2, 2,
          0, 0, 1, 2,
          0, 0, 0, 2,
          1, 1, 1, 2,
          0, 1, 1, 2,
          0, 0, 0, 2,
          0, 0, 0, 2,
          0, 1, 2, 2,
          1, 1, 0, 0
  ], 4, 11, true, false);

  var fragment = document.createDocumentFragment();

  var i, sprite;
  for (i = 0; i < SPRITE_COUNT; i++) {
      sprite = new Sprite(spaceship, true);
      fragment.append(resize(sprite.canvas, SPRITE_SCALE));
  }

  fragment.append(document.createElement('hr'));

  for (i = 0; i < SPRITE_COUNT; i++) {
      sprite = new Sprite(dragon, true);
      fragment.append(resize(sprite.canvas, SPRITE_SCALE));
  }

  fragment.append(document.createElement('hr'));

  for (i = 0; i < SPRITE_COUNT; i++) {
      sprite = new Sprite(robot, true);
      fragment.append(resize(sprite.canvas, SPRITE_SCALE));
  }
  
  document.body.append(fragment);
}

CanvasElement resize(CanvasElement img, num scale) {
    var widthScaled  = img.width * scale;
    var heightScaled = img.height * scale;
    
    var orig    = document.createElement('canvas');
    orig.width  = img.width;
    orig.height = img.height;

    var origCtx = orig.getContext('2d');

    origCtx.drawImage(img, 0, 0);

    var origPixels   = origCtx.getImageData(0, 0, img.width, img.height);
    var scaled       = document.createElement('canvas');
    scaled.width     = widthScaled;
    scaled.height    = heightScaled;
    var scaledCtx    = scaled.getContext('2d');
    var scaledPixels = scaledCtx.getImageData( 0, 0, widthScaled, heightScaled );
    
    for( var y = 0; y < heightScaled; y++ ) {
        for( var x = 0; x < widthScaled; x++ ) {
            var index = ((y / scale).floor() * img.width + (x / scale).floor()) * 4;
            var indexScaled = (y * widthScaled + x) * 4;

            scaledPixels.data[ indexScaled ]   = origPixels.data[ index ];
            scaledPixels.data[ indexScaled+1 ] = origPixels.data[ index+1 ];
            scaledPixels.data[ indexScaled+2 ] = origPixels.data[ index+2 ];
            scaledPixels.data[ indexScaled+3 ] = origPixels.data[ index+3 ];
        }
    }

    scaledCtx.putImageData( scaledPixels, 0, 0 );

    return scaled;
}