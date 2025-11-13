// Top Stacking Game (Processing)
// - 상단 1/5 지점에서 블록이 좌우 이동
// - 스페이스바로 내려앉아 겹침 계산
// - 벗어난 조각은 part로 떨어지며 페이드아웃
// - 겹침이 0이면 게임오버

ArrayList<Object> stack;
// 쌓인 층들 (맨 아래 토대 포함)

ArrayList<Part> parts;
// 떨어지는 파편들

Block current;
// 현재 이동 중인 블록

// 게임 상태
boolean isGameOver = false;
int score = 0;                // 쌓은 층 수 (토대 제외)

// 비주얼 설정
int bgColor = color(18, 18, 22);
int baseColor = color(70, 140, 255);
int blockColor = color(90, 200, 255);
int partColor = color(255, 120, 120);

float laneYTopRate = 0.20;   // 생성 Y (상단 1/5 지점)
float blockHeight = 50;      // 모든 층 높이
float baseWidthRate = 0.55;  // 초기 토대 너비 비율
float moveSpeed = 4.0;       // 좌우 이동 속도

// 카메라(월드 변환)
float camShiftY = 0;         // 화면에 적용할 Y 방향 translate
float topKeepMargin = 0.7;  // 화면 상단에서 유지할 마진 비율

void setup() {
	size(480, 720);
	rectMode(CENTER);
	textAlign(CENTER, CENTER);
	noStroke();
	resetGame();
}

void resetGame() {
	stack = new ArrayList<Object>();
	parts = new ArrayList<Part>();
	isGameOver = false;
	score = 0;

	// 바닥 토대 생성 (화면 바닥에서 블록 높이만큼 올라온 위치)
	float baseW = width * baseWidthRate;
	PVector basePos = new PVector(width/2.0, height - blockHeight/2.0);
	Object base = new Object(basePos, baseW, blockHeight);
	base.col = randomLayerColor();
	stack.add(base);

	camShiftY = 0;

	spawnNewBlock(baseW);
}

void spawnNewBlock(float w) {
	// 카메라 보정: 화면 기준 위치(height*laneYTopRate)를 월드 좌표로 변환
	float y = height * laneYTopRate - camShiftY;
	float dir = random(1) < 0.5 ? -1 : 1;
	// 화면을 좌우 왕복하도록 시작 X는 랜덤, 방향도 랜덤
	float x = random(w/2, width - w/2);
	current = new Block(new PVector(x, y), w, blockHeight, moveSpeed * dir);
	current.col = randomLayerColor();
}

void draw() {
	background(bgColor);

	// 카메라(월드) 이동 계산: 가장 위 층을 threshold 위치로 유지
	Object top = stack.get(stack.size()-1);
	float thresholdY = height * topKeepMargin;
	float desired = max(0, thresholdY - top.position.y);
	camShiftY = lerp(camShiftY, desired, 0.30); // 반응 속도 상향

	// 월드 렌더: translate로 좌표계를 이동하고 원래 좌표로 그린다
	translate(0, camShiftY);

	// 쌓인 층 렌더링
	for (int i = 0; i < stack.size(); i++) {
		Object o = stack.get(i);
		if (o.col != -1) fill(o.col); else fill(baseColor);
		rect(o.position.x, o.position.y, o.width, o.height);
	}

	// 현재 이동 블록 업데이트 및 렌더링 (게임오버가 아닐 때만)
	if (!isGameOver && current != null) {
		current.updateHorizontalBounce(0 + current.width/2.0, width - current.width/2.0);
		fill(current.col);
		rect(current.position.x, current.position.y, current.width, current.height);
	}

	// 파편 업데이트/렌더링
			for (int i = parts.size()-1; i >= 0; i--) {
				Part p = parts.get(i);
				p.update();
				p.drawSelf();
				if (p.isDead(height, camShiftY)) {
					parts.remove(i);
				}
			}

	// 역변환으로 좌표계를 복원
	translate(0, -camShiftY);

	// UI
	drawUI();
}

void drawUI() {
	fill(255);
	textSize(16);
	text("Score: " + score, width - 70, 24);

	if (isGameOver) {
		textSize(28);
		fill(255);
		text("Game Over", width/2, height/2 - 20);
		textSize(16);
		fill(200);
		text("Press R to Restart", width/2, height/2 + 14);
	} else {
		textSize(14);
		fill(200);
		text("Space: Drop", width/2, 24);
	}
}

void keyPressed() {
	if (key == 'r' || key == 'R') {
		resetGame();
		return;
	}
	if (isGameOver) return;

	// 스페이스바로 쌓기
	if (key == ' ' && current != null) {
		settleCurrentBlock();
	}
}

void settleCurrentBlock() {
	// 마지막 층 (기준)이 되는 오브젝트
	Object base = stack.get(stack.size()-1);

	// 현재 블록을 마지막 층 바로 위로 이동 (시각적 정렬)
	current.position.y = base.position.y - (base.height/2.0) - (current.height/2.0);

	// 겹침 계산
	float leftA = current.position.x - current.width/2.0;
	float rightA = current.position.x + current.width/2.0;
	float leftB = base.position.x - base.width/2.0;
	float rightB = base.position.x + base.width/2.0;

	float overlapLeft = max(leftA, leftB);
	float overlapRight = min(rightA, rightB);
	float overlapW = overlapRight - overlapLeft;

	if (overlapW <= 0) {
		// 전부 벗어남: 현재 블록 전체를 파편으로 만들고 게임오버
		makePartFromSegment(current.position.y, leftA, current.width);
		current = null;
		isGameOver = true;
		return;
	}

	// 겹치는 부분을 새로운 층으로 추가
	float newCx = (overlapLeft + overlapRight) / 2.0;
	float newCy = base.position.y - base.height/2.0 - current.height/2.0; // 이미 맞춰둠
	Object newLayer = new Object(new PVector(newCx, newCy), overlapW, current.height);
	newLayer.col = current.col;
	stack.add(newLayer);
	score++;

	// 왼쪽 초과 부분
	if (leftA < overlapLeft) {
		float excessW = overlapLeft - leftA;
		makePartFromSegment(newCy, leftA, excessW);
	}
	// 오른쪽 초과 부분
	if (rightA > overlapRight) {
		float excessW = rightA - overlapRight;
		float segLeft = overlapRight;
		makePartFromSegment(newCy, segLeft, excessW);
	}

	// 다음 라운드 블록 생성 (겹친 너비로)
	spawnNewBlock(overlapW);
}

// 화면 상의 세그먼트(left, width)를 part로 생성하여 낙하시킴
void makePartFromSegment(float centerY, float segLeft, float segW) {
	float cx = segLeft + segW/2.0;
		Part p = new Part(new PVector(cx, centerY), segW, blockHeight);
	p.vel = new PVector((cx < width/2.0) ? -2.0 : 2.0, 0.5);
		p.col = (current != null) ? current.col : partColor;
	parts.add(p);
}

	// 층별 랜덤 색상(보기 좋은 밝기 범위)
	int randomLayerColor() {
		float r = random(60, 255);
		float g = random(60, 255);
		float b = random(60, 255);
		return color(r, g, b);
	}

