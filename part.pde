class Part extends Object {
	PVector vel = new PVector(0, 0);
	float alpha = 255;
	int col = -1; // 파편의 원본 색

	Part(PVector pos, float w, float h) {
		super(pos, w, h);
	}

	void update() {
		vel.y += 0.6;
		position.add(vel);
		alpha -= 4.0;
		if (alpha < 0) alpha = 0;
	}

	void drawSelf() {
		if (col == -1) fill(255, alpha); else fill(col, alpha);
		rect(position.x, position.y, width, height);
	}

	boolean isDead(int screenH, float shiftY) {
		// 화면 하단(월드좌표: height - shiftY) 아래로 충분히 떨어지면 제거
		return alpha <= 0 || position.y - height/2.0 > (screenH - shiftY) + 80;
	}
}