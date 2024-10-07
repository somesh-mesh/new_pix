import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pixabay/constants/api_interface.dart';
import 'package:pixabay/data/get_images_model.dart';

class PixabayImagesList extends StatefulWidget {
  const PixabayImagesList({super.key});

  @override
  State<PixabayImagesList> createState() => _PixabayImagesListState();
}

class _PixabayImagesListState extends State<PixabayImagesList> {
  GetImagesModel? getImagesModel;
  List<Hits>? hits = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getImageList();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Grid Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Gallery'),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text('Failed to load images: $errorMessage'))
            : Column(
          children: [
            Expanded(
              child: VideoGrid(
                imageList: hits,
                scrollController: _scrollController,
              ),
            ),
            if (isLoadingMore)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
        !isLoadingMore) {
      loadMoreImages();
    }
  }

  void getImageList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final onValue = await ApiInterFace().fetchVideos("yellow+flowers", page: currentPage);
      if (onValue?.statusCode == 200) {
        setState(() {
          hits = onValue?.hits ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error: Unknown error';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void loadMoreImages() async {
    setState(() {
      isLoadingMore = true;
    });
    currentPage++;

    try {
      final onValue = await ApiInterFace().fetchVideos("yellow+flowers", page: currentPage);
      if (onValue?.statusCode == 200) {
        setState(() {
          hits?.addAll(onValue?.hits ?? []);
          isLoadingMore = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error: Unknown error';
          isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoadingMore = false;
      });
    }
  }
}

class VideoGrid extends StatelessWidget {
  final List<Hits>? imageList;
  final ScrollController? scrollController;

  VideoGrid({this.imageList, this.scrollController});

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

          return GestureDetector(
            onTap: () {
              // Show dialog when tapped
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
            },
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
                        const Icon(
                          Icons.thumb_up,
                          color: Colors.red,
                        ),
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
        },
      ),
    );
  }
}
