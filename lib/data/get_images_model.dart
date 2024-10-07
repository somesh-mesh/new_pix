class GetImagesModel {
  int? total;
  int? totalHits;
  List<Hits>? hits;
  int? statusCode;

  GetImagesModel({this.total, this.totalHits, this.hits, this.statusCode});

  GetImagesModel.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    total = json['total'];
    totalHits = json['totalHits'];
    this.statusCode = statusCode; // Capture the statusCode
    if (json['hits'] != null) {
      hits = <Hits>[];
      json['hits'].forEach((v) {
        hits!.add(Hits.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['totalHits'] = totalHits;
    data['statusCode'] = statusCode;
    if (hits != null) {
      data['hits'] = hits!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Hits {
  int? id;
  String? pageURL;
  String? type;
  String? tags;
  int? duration;
  Videos? videos;
  int? views;
  int? downloads;
  int? likes;
  int? comments;
  int? userId;
  String? user;
  String? userImageURL;

  Hits(
      {this.id,
        this.pageURL,
        this.type,
        this.tags,
        this.duration,
        this.videos,
        this.views,
        this.downloads,
        this.likes,
        this.comments,
        this.userId,
        this.user,
        this.userImageURL});

  Hits.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pageURL = json['pageURL'];
    type = json['type'];
    tags = json['tags'];
    duration = json['duration'];
    videos = json['videos'] != null ? Videos.fromJson(json['videos']) : null;
    views = json['views'];
    downloads = json['downloads'];
    likes = json['likes'];
    comments = json['comments'];
    userId = json['user_id'];
    user = json['user'];
    userImageURL = json['userImageURL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['pageURL'] = pageURL;
    data['type'] = type;
    data['tags'] = tags;
    data['duration'] = duration;
    if (videos != null) {
      data['videos'] = videos!.toJson();
    }
    data['views'] = views;
    data['downloads'] = downloads;
    data['likes'] = likes;
    data['comments'] = comments;
    data['user_id'] = userId;
    data['user'] = user;
    data['userImageURL'] = userImageURL;
    return data;
  }
}

class Videos {
  Large? large;
  Large? medium;
  Large? small;
  Large? tiny;

  Videos({this.large, this.medium, this.small, this.tiny});

  Videos.fromJson(Map<String, dynamic> json) {
    large = json['large'] != null ? Large.fromJson(json['large']) : null;
    medium = json['medium'] != null ? Large.fromJson(json['medium']) : null;
    small = json['small'] != null ? Large.fromJson(json['small']) : null;
    tiny = json['tiny'] != null ? Large.fromJson(json['tiny']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (large != null) {
      data['large'] = large!.toJson();
    }
    if (medium != null) {
      data['medium'] = medium!.toJson();
    }
    if (small != null) {
      data['small'] = small!.toJson();
    }
    if (tiny != null) {
      data['tiny'] = tiny!.toJson();
    }
    return data;
  }
}

class Large {
  String? url;
  int? width;
  int? height;
  int? size;
  String? thumbnail;

  Large({this.url, this.width, this.height, this.size, this.thumbnail});

  Large.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    width = json['width'];
    height = json['height'];
    size = json['size'];
    thumbnail = json['thumbnail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['width'] = width;
    data['height'] = height;
    data['size'] = size;
    data['thumbnail'] = thumbnail;
    return data;
  }
}