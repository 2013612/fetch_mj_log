class Log {
  String id;
  int pos;

  Log(this.id, this.pos);

  @override
  bool operator ==(Object other) {
    return other is Log && other.id == id && other.pos == pos;
  }

  @override
  int get hashCode => Object.hash(id, pos);
}
