import 'dart:html';
import 'package:pixel_sprite_generator/pixel_sprite_generator.dart' as psg;

void main() {
  window.onLoad.listen((e) => createExample());
}

void createExample() {
  var SPRITE_SCALE = 2;
  var SPRITE_COUNT = 100;

  var spaceship = new psg.Mask([
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

  var dragon = new psg.Mask([
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

  var robot = new psg.Mask([
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

  var i, sprite, div;

  // Example 1
  div = document.createElement('div');
  div.text = 'Colored ship sprites';
  div.append(document.createElement('hr'));

  for (i = 0; i < SPRITE_COUNT; i++) {
    sprite = new psg.Sprite(spaceship, new psg.SpriteOptions(colored: true));
      div.append(resize(sprite.canvas, SPRITE_SCALE));
  }

  fragment.append(div);

  // Example 2
  div = document.createElement('div');
  div.text = 'Colored ship sprites (with low saturation)';
  div.append(document.createElement('hr'));

  for (i = 0; i < SPRITE_COUNT; i++) {
      sprite = new psg.Sprite(spaceship, new psg.SpriteOptions(colored: true));
      // TODO: saturation      : 0.1
      div.append(resize(sprite.canvas, SPRITE_SCALE));
  }

  fragment.append(div);

  // Example 3
  div = document.createElement('div');
  div.text = 'Colored ship sprites (with many color variations per ship)';
  div.append(document.createElement('hr'));

  for (i = 0; i < SPRITE_COUNT; i++) {
    sprite = new psg.Sprite(spaceship, new psg.SpriteOptions(colored: true, colorVariations: 0.9, saturation: 0.8));
    div.append(resize(sprite.canvas, SPRITE_SCALE));
  }

  fragment.append(div);

  // Example 4
  div = document.createElement('div');
  div.text = 'Colored dragon sprites';
  div.append(document.createElement('hr'));

  for (i = 0; i < SPRITE_COUNT; i++) {
    sprite = new psg.Sprite(dragon, new psg.SpriteOptions(colored: true));
    div.append(resize(sprite.canvas, SPRITE_SCALE));
  }

  fragment.append(div);

  // Example 5
  div = document.createElement('div');
  div.text = 'Black & white robot sprites';
  div.append(document.createElement('hr'));

  for (i = 0; i < SPRITE_COUNT; i++) {
    sprite = new psg.Sprite(robot);
    div.append(resize(sprite.canvas, SPRITE_SCALE));
  }
  
  fragment.append(div);
  
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