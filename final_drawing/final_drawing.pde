PGraphics brushLayer;
PGraphics cursorLayer;

float brushX, brushY;
float cursorX, cursorY;
float brushSpeed = 2.5;
float avoidanceRadius = 100;
float randomAngle;
float centerPullStrength = 6;
float edgeRepulsionStrength = 2;

PImage cursorGrab;
PImage cursorIdle;
PImage brushIcon;
PImage menuImage;

float brushIconSize = 30;
boolean showWarning = false;
int warningTimer = 0;
int warningDuration = 120;

void setup() {
  size(900, 700, P2D);
  noCursor();

  brushLayer = createGraphics(width, height, P2D);
  brushLayer.beginDraw();
  brushLayer.background(255);
  brushLayer.endDraw();

  cursorLayer = createGraphics(width, height, P2D);

  cursorGrab = loadImage("cursor-grab.png");
  cursorIdle = loadImage("cursor.png");
  brushIcon = loadImage("brush.png");
  menuImage = loadImage("menu.png");

  brushX = width / 2;
  brushY = height / 2;
  cursorX = width / 2;
  cursorY = height / 2;
  randomAngle = random(TWO_PI);
}

void draw() {
  background(255);

  // Update fake cursor (inverted and slowed)
  float invertedX = width - mouseX;
  float invertedY = height - mouseY;
  cursorX = lerp(cursorX, invertedX, 0.005);
  cursorY = lerp(cursorY, invertedY, 0.005);

  float d = dist(brushX, brushY, cursorX, cursorY);
  float moveX = 0;
  float moveY = 0;

  if (d < avoidanceRadius) {
    float angle = atan2(brushY - cursorY, brushX - cursorX);
    float superSpeed = brushSpeed * 10;
    moveX = cos(angle) * superSpeed;
    moveY = sin(angle) * superSpeed;
  } else {
    randomAngle += random(-PI / 16, PI / 16);
    moveX = cos(randomAngle) * brushSpeed;
    moveY = sin(randomAngle) * brushSpeed;
  }

  // Center pull to drawing area center
  float centerX = (100 + 875) / 2.0;
  float centerY = (175 + 600) / 2.0;
  float toCenterX = centerX - brushX;
  float toCenterY = centerY - brushY;
  moveX += toCenterX * centerPullStrength / width;
  moveY += toCenterY * centerPullStrength / height;

  // Repulsion from edges of drawing area
  if (brushX < 100) moveX += edgeRepulsionStrength;
  if (brushX > 875) moveX -= edgeRepulsionStrength;
  if (brushY < 175) moveY += edgeRepulsionStrength;
  if (brushY > 600) moveY -= edgeRepulsionStrength;

  float prevBrushX = brushX;
  float prevBrushY = brushY;

  brushX += moveX;
  brushY += moveY;

  brushX = constrain(brushX, 100, 875);
  brushY = constrain(brushY, 175, 600);

  // Draw brush trail
  brushLayer.beginDraw();
  brushLayer.stroke(0);
  brushLayer.strokeWeight(4);
  brushLayer.line(prevBrushX, prevBrushY, brushX, brushY);
  brushLayer.endDraw();
  image(brushLayer, 0, 0);

  // UI image on top of drawing
  image(menuImage, 0, 0, 900, 700);

  // Brush icon
  image(brushIcon, brushX - brushIconSize / 3, brushY - brushIconSize, brushIconSize, brushIconSize);

  // Determine if fake cursor is inside drawing bounds
  boolean fakeInside = (cursorX >= 100 && cursorX <= 875 && cursorY >= 175 && cursorY <= 600);
  PImage currentCursor = fakeInside ? cursorGrab : cursorIdle;

  // Draw fake cursor
  cursorLayer.beginDraw();
  cursorLayer.clear();

  if (fakeInside) {
    cursorLayer.image(currentCursor, cursorX - currentCursor.width / 2, cursorY - currentCursor.height / 2);
  } else {
    float scale = 0.35;
    float scaledW = currentCursor.width * scale;
    float scaledH = currentCursor.height * scale;
    cursorLayer.image(currentCursor, cursorX - scaledW / 2, cursorY - scaledH / 2, scaledW, scaledH);
  }

  cursorLayer.endDraw();
  image(cursorLayer, 0, 0);

  // Warning message
  if (showWarning) {
    fill(255, 0, 0);
    textAlign(CENTER, CENTER);
    textSize(22);
    text("Please first capture the brush before proceeding with further action", width / 2, height / 2);
    warningTimer--;
    if (warningTimer <= 0) showWarning = false;
  }
}

void mousePressed() {
  // Check if fake cursor is inside the drawing area
  boolean fakeInside = (cursorX >= 100 && cursorX <= 875 && cursorY >= 175 && cursorY <= 600);
  if (!fakeInside) {
    showWarning = true;
    warningTimer = warningDuration;
  }
}
