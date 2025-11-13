class Object {
    PVector position;
    float width;
    float height = 50;
    int col = -1; // 각 층의 고유 색(미설정시 -1)

    Object(PVector pos, float w, float h) {
        position = pos;
        width = w;
        height = h;
    }
}