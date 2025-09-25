import 'dart:io';
import 'package:flutter/material.dart';
import 'common/fallback_background.dart';

class ImageSelectionWidget extends StatelessWidget {
  final List<File> selectedImages;
  final VoidCallback onPickImage;
  final Function(int) onRemoveImage;

  const ImageSelectionWidget({
    super.key,
    required this.selectedImages,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: selectedImages.isEmpty
            ? _EmptyState(onTap: onPickImage)
            : _ImageGrid(
                images: selectedImages,
                onRemoveImage: onRemoveImage,
                onAddMore: onPickImage,
              ),
      );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 48,
              color: Theme.of(context).primaryColor.withOpacity(0.6),
            ),
            const SizedBox(height: 12),
            Text(
              '点击选择图片',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageGrid extends StatelessWidget {
  final List<File> images;
  final Function(int) onRemoveImage;
  final VoidCallback onAddMore;

  const _ImageGrid({
    required this.images,
    required this.onRemoveImage,
    required this.onAddMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 图片网格
        Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) => _ImageItem(
              image: images[index],
              onRemove: () => onRemoveImage(index),
            ),
          ),
        ),
        // 添加更多图片按钮
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: OutlinedButton.icon(
            onPressed: onAddMore,
            icon: const Icon(Icons.add),
            label: const Text('添加更多图片'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
              side: BorderSide(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageItem extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;

  const _ImageItem({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.file(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return FallbackBackgrounds.imageSelection();
                },
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 16),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
              ),
            ),
          ],
        ),
      );
}
