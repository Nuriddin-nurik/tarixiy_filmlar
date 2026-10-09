import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/comment_model.dart';
import '../controllers/comments_controller.dart';

String commentTime(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inMinutes < 1) return 'Hozirgina'.tr;
  if (diff.inMinutes < 60) return '@n daqiqa oldin'.trParams({'n': '${diff.inMinutes}'});
  if (diff.inHours < 24) return '@n soat oldin'.trParams({'n': '${diff.inHours}'});
  if (diff.inDays < 7) return '@n kun oldin'.trParams({'n': '${diff.inDays}'});
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(t.day)}.${two(t.month)}.${t.year}';
}

TextStyle _style(double size, FontWeight w, Color c, {double? height}) =>
    TextStyle(fontFamily: AppFonts.jakarta, fontSize: size.sp, fontWeight: w, color: c, height: height);

Future<void> showCommentsSheet(CommentsController controller, {bool focusInput = false}) {
  return Get.bottomSheet(
    _CommentsSheet(controller: controller, focusInput: focusInput),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class CommentAvatar extends StatelessWidget {
  const CommentAvatar({super.key, required this.name, this.size = 36});
  final String name;
  final double size;

  static const _palette = [
    Color(0xFF2E7D5B),
    Color(0xFF8A6D1F),
    Color(0xFF3A5BA0),
    Color(0xFF8E3B46),
    Color(0xFF5B4B8A),
    Color(0xFF2F7A8C),
  ];

  @override
  Widget build(BuildContext context) {
    final letter = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    final color = _palette[name.hashCode.abs() % _palette.length];
    return Container(
      width: size.w,
      height: size.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(letter, style: _style(size * 0.42, FontWeight.w700, Colors.white)),
    );
  }
}

class CommentTile extends StatelessWidget {
  const CommentTile({super.key, required this.comment, this.onMenu, this.maxLines});
  final CommentModel comment;
  final VoidCallback? onMenu;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final name = comment.authorName.isEmpty ? 'Foydalanuvchi'.tr : comment.authorName;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentAvatar(name: name),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      comment.mine ? '$name (${'siz'.tr})' : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _style(12.5, FontWeight.w700, Colors.white),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(commentTime(comment.createdAt), style: _style(10.5, FontWeight.w400, AppColors.textSecondary)),
                ],
              ),
              SizedBox(height: 3.h),
              Text(
                comment.text,
                maxLines: maxLines,
                overflow: maxLines == null ? null : TextOverflow.ellipsis,
                style: _style(13, FontWeight.w400, Colors.white.withValues(alpha: 0.88), height: 1.4),
              ),
            ],
          ),
        ),
        if (onMenu != null)
          InkResponse(
            onTap: onMenu,
            radius: 18.r,
            child: Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Icon(Icons.more_vert_rounded, color: AppColors.textSecondary, size: 18.sp),
            ),
          ),
      ],
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({required this.controller, required this.focusInput});
  final CommentsController controller;
  final bool focusInput;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();

  CommentsController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) c.loadMore();
    });
    if (widget.focusInput) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (await c.send(_input.text)) {
      _input.clear();
      if (_scroll.hasClients) _scroll.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  void _openMenu(CommentModel comment) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (comment.mine)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE57373)),
                  title: Text("O'chirish".tr, style: _style(14, FontWeight.w600, const Color(0xFFE57373))),
                  onTap: () {
                    Get.back();
                    _confirmDelete(comment);
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: Colors.white),
                  title: Text('Shikoyat qilish'.tr, style: _style(14, FontWeight.w600, Colors.white)),
                  onTap: () {
                    Get.back();
                    c.report(comment);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(CommentModel comment) {
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text("Izohni o'chirasizmi?".tr, style: _style(16, FontWeight.w700, Colors.white)),
      actions: [
        TextButton(onPressed: Get.back, child: Text('Bekor qilish'.tr)),
        TextButton(
          onPressed: () {
            Get.back();
            c.delete(comment);
          },
          child: Text("O'chirish".tr, style: const TextStyle(color: Color(0xFFE57373))),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;
    final height = (MediaQuery.of(context).size.height - insets) * 0.85;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.seriesBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Column(
        children: [
          SizedBox(height: 8.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2.r)),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 8.w, 6.h),
            child: Row(
              children: [
                Obx(() => Text(
                      '${'Izohlar'.tr} (${c.total.value})',
                      style: _style(16, FontWeight.w700, Colors.white),
                    )),
                const Spacer(),
                IconButton(
                  onPressed: Get.back,
                  icon: Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22.sp),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
          Expanded(
            child: Obx(() {
              if (c.items.isEmpty && c.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.seriesGreen));
              }
              if (c.items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textSecondary, size: 40.sp),
                        SizedBox(height: 12.h),
                        Text(
                          "Hali izoh yo'q. Birinchi bo'lib fikr bildiring!".tr,
                          textAlign: TextAlign.center,
                          style: _style(13, FontWeight.w500, AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.seriesGreen,
                onRefresh: c.refreshComments,
                child: ListView.separated(
                  controller: _scroll,
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 12.w, 14.h),
                  itemCount: c.items.length + (c.hasMore.value ? 1 : 0),
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (_, i) {
                    if (i >= c.items.length) {
                      return Padding(
                        padding: EdgeInsets.all(8.w),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.seriesGreen),
                          ),
                        ),
                      );
                    }
                    final comment = c.items[i];
                    return CommentTile(comment: comment, onMenu: () => _openMenu(comment));
                  },
                ),
              );
            }),
          ),
          Container(
            padding:
                EdgeInsets.fromLTRB(12.w, 8.h, 8.w, 8.h + (insets > 0 ? 0 : MediaQuery.of(context).padding.bottom)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    focusNode: _focus,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 1000,
                    textCapitalization: TextCapitalization.sentences,
                    style: _style(14, FontWeight.w400, Colors.white),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'Fikringizni yozing...'.tr,
                      hintStyle: _style(14, FontWeight.w400, AppColors.textSecondary),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                Obx(() => IconButton(
                      onPressed: c.isSending.value ? null : _send,
                      icon: c.isSending.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.seriesGreen),
                            )
                          : Icon(Icons.send_rounded, color: AppColors.seriesGreen, size: 24.sp),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
