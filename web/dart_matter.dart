library dart_matter;

//dart SDK files
import 'dart:html';
import 'dart:web_gl' as webgl;
import 'dart:math' as math;

import 'land_tile.dart';

import 'package:vector_math/vector_math.dart';

import 'camera.dart' as cam;

class dart_matter {


  int area = 10;
  int quality = 3;


  int baseSystemSize = 129;

  land_tile baseTile = new land_tile();

  List container;

  webgl.RenderingContext gl;
  CanvasElement canvas;

  Matrix4 projectionMat;
  var camera;

  dart_matter(webgl.RenderingContext givenGL, CanvasElement givenCanvas) {
    gl = givenGL;
    canvas = givenCanvas;

    camera = new cam.camera(canvas);

    projectionMat = makePerspectiveMatrix(45, (canvas.width / canvas.height), 1, 1000);
    setPerspectiveMatrix(projectionMat, 45, (canvas.width / canvas.height), 1.0, 1000.0);

    gl.clearColor(0.5, 0.5, 0.5, 1.0);
    gl.clearDepth(1.0);
    gl.enable(webgl.RenderingContext.DEPTH_TEST);
  }

  draw() {
    Matrix4 viewMat = camera.getViewMat();

    gl.clear(webgl.RenderingContext.COLOR_BUFFER_BIT | webgl.RenderingContext.DEPTH_BUFFER_BIT);

    for (int i = 0; i < container.length; i++) {
      for (int j = 0; j < container[i].length; j++) {
        if (container[i][j] != null) {
          container[i][j].draw(viewMat, projectionMat);
        }
      }
    }
    //container[3][3].draw(viewMat, projectionMat);
  }

  update() {
    //aunto config runtime aspect runs here
    camera.update();
  }

  initState() {
    double ratio = (area + quality) / quality;
    if (ratio > 0.5) {
      baseSystemSize = 129;
    } else if (ratio > 0.25) {
      baseSystemSize = 65;
    } else {
      baseSystemSize = 33;
    }

    //auto config creation aspect runs here
    baseTile.generate(0, 0, baseSystemSize, gl);//start location of base tile

    container = new List();
    container.add(new List<land_tile>());
    container[0].add(baseTile);

    baseTile.CreateHeightMap(container);
    baseTile.CreateObject(container);

    print(baseTile.genTime);
    print(baseTile.runTime);
    
    int genTime = baseTile.genTime + baseTile.runTime;
  }

  setup() {
    print("setup");
    initState();


    container = new List();

    
    //based on the base system size, create defult grid
    int containerSize;
    if (baseSystemSize == 129) {
      containerSize = 7;
    } else if (baseSystemSize == 65) {
      containerSize = 5;
    } else {
      containerSize = 3;
    }


    for (int i = 0; i < containerSize; i++) {
      container.add(new List<land_tile>());
      for (int j = 0; j < containerSize; j++) {
        container[i].add(null);
      }
    }
    //baseTile = new land_tile();
    //baseTile.generate((containerSize - 1) ~/ 2, (containerSize - 1) ~/ 2, 1/*baseSystemSize*/, gl);
    container[(containerSize - 1) ~/ 2][(containerSize - 1) ~/ 2] = baseTile;
    //print(container[1][1]);
    print((containerSize - 1) / 2);
    for (int i = 0; i < container.length; i++) {
      for (int j = 0; j < container[i].length; j++) {

        double difI = i - (containerSize) / 2;
        double difJ = j - (containerSize) / 2;

        difI = difI.abs();
        difJ = difJ.abs();

        if (difI + difJ == 1) {
          container[i][j] = new land_tile();
          container[i][j].generate(i, j, baseSystemSize, gl);
        } else if ((difI + difJ == 2) || (difI == 1.5) && (difJ == 1.5)) {
          container[i][j] = new land_tile();
          container[i][j].generate(i, j, baseSystemSize, gl);
        } else if ((difI + difJ == 3)) {
          container[i][j] = new land_tile();
          container[i][j].generate(i, j, baseSystemSize, gl);
        }
      }
    }


    List temptwo;
    temptwo = new List();
    for (int i = 0; i < containerSize; i++) {
      temptwo.add(new List());
      for (int j = 0; j < containerSize; j++) {
        temptwo[i].add(0);
      }
    }

    for (int i = 0; i < container.length; i++) {
      for (int j = 0; j < container[i].length; j++) {
        if (container[i][j] != null) {
          temptwo[i][j] = container[i][j].res;
        }
      }
    }

    for (int i = 0; i < containerSize; i++) {
      print(temptwo[i]);
    }

    // *
    //* code to add a new tile to the grid and container
    List tempnew = new List<land_tile>();
    tempnew.add(new land_tile());
    tempnew[0].generate(1, 1, 9, gl);
    print(tempnew[0].res);


/*    container[1].add(null);
    container[1][container[1].length-1] = new land_tile();
    container[1][container[1].length-1].generate(1, container[1].length, 3, gl); 
    
    print(container[1][container[1].length-1].res);*/
    //*/
    //base system has been created and is stored within the "container" class.
    //tempnew is a test to find what values are stored within the grid, and the current resolution of each tile

    //now to create the tiles
    //create the tiles with the lowest resolution first
    for (int i = 0; i < container.length; i++) {
      for (int j = 0; j < container[i].length; j++) {
        if (container[i][j] != null) {
          if (container[i][j].res == ((baseSystemSize) ~/ 4) + 1) {
            container[i][j].CreateHeightMap(container);
          }
        }
      }
    }

    for (int i = 0; i < container.length; i++) {
      for (int j = 0; j < container[i].length; j++) {
        if (container[i][j] != null) {
          if (container[i][j].res == (baseSystemSize + 1) ~/ 2) {
            container[i][j].CreateHeightMap(container);
          }
        }
      }
    }
    for (int i = 0; i < container.length; i++) {
      for (int j = 0; j < container[i].length; j++) {
        if (container[i][j] != null) {
          if (container[i][j].res == baseSystemSize) {
            container[i][j].CreateHeightMap(container);
          }
        }
      }
    }
    for (int i = 0; i < container.length; i++) {
      for (int j = 0; j < container[i].length; j++) {
        if (container[i][j] != null) {
          if (container[i][j].res == ((baseSystemSize) ~/ 4) + 1) {
            container[i][j].CreateObject(container);
          }
        }
      }
    }

    for (int i = 0; i < container.length; i++) {
      for (int j = 0; j < container[i].length; j++) {
        if (container[i][j] != null) {
          if (container[i][j].res == (baseSystemSize + 1) ~/ 2) {
            container[i][j].CreateObject(container);
          }
        }
      }
    }
    for (int i = 0; i < container.length; i++) {
      for (int j = 0; j < container[i].length; j++) {
        if (container[i][j] != null) {
          if (container[i][j].res == baseSystemSize) {
            container[i][j].CreateObject(container);
          }
        }
      }
    }



  }



}
