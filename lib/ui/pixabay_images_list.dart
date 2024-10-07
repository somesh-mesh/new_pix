import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pixabay/constants/api_interface.dart';
import 'package:pixabay/data/get_images_model.dart';

class PixabayApp extends StatelessWidget {
  const PixabayApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixabay Gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PixabayImagesList(),
    );
  }
}

class PixabayImagesList extends StatefulWidget {
  const PixabayImagesList({Key? key}) : super(key: key);

  @override
  State<PixabayImagesList> createState() => _PixabayImagesListState();
}

class _PixabayImagesListState extends State<PixabayImagesList> {
  List<Hits>? _hits = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchImageList();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pixabay Gallery'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text('Failed to load images: $_errorMessage'));
    }
    return Column(
      children: [
        Expanded(
          child: ImageGrid(
            imageList: _hits,
            scrollController: _scrollController,
          ),
        ),
        if (_isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      _loadMoreImages();
    }
  }

  Future<void> _fetchImageList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiInterFace().fetchVideos("yellow+flowers", page: _currentPage);
      if (response?.statusCode == 200) {
        setState(() {
          _hits = response?.hits ?? [];
          _isLoading = false;
        });
      } else {
        _showError('Unknown error occurred.');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  Future<void> _loadMoreImages() async {
    setState(() {
      _isLoadingMore = true;
    });
    _currentPage++;

    try {
      final response = await ApiInterFace().fetchVideos("yellow+flowers", page: _currentPage);
      if (response?.statusCode == 200) {
        setState(() {
          _hits?.addAll(response?.hits ?? []);
          _isLoadingMore = false;
        });
      } else {
        _showError('Unknown error occurred while loading more images.');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
      _isLoadingMore = false;
    });
  }
}

class ImageGrid extends StatelessWidget {
  final List<Hits>? imageList;
  final ScrollController? scrollController;

  const ImageGrid({Key? key, this.imageList, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        controller: scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.7,
        ),
        itemCount: imageList?.length ?? 0,
        itemBuilder: (context, index) {
          final video = imageList?[index];
          final imageUrl = video?.videos?.large?.thumbnail ?? '';
          return ImageGridItem(imageUrl: imageUrl, video: video);
        },
      ),
    );
  }
}

class ImageGridItem extends StatelessWidget {
  final String imageUrl;
  final Hits? video;

  const ImageGridItem({Key? key, required this.imageUrl, required this.video}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageDialog(context, imageUrl, video),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: GridTile(
            footer: GridTileBar(
              backgroundColor: Colors.black54,
              title: Row(
                children: [
                  const Icon(Icons.thumb_up, color: Colors.red),
                  const SizedBox(width: 5),
                  Text(
                    video?.likes.toString() ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl, Hits? video) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Likes: ${video?.likes ?? 0}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}

