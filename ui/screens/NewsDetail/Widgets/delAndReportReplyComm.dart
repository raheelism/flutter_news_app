import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:news/data/models/CommentModel.dart';
import 'package:news/ui/widgets/customTextBtn.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/NewsComment/deleteCommentCubit.dart';
import 'package:news/cubits/NewsComment/flagCommentCubit.dart';
import 'package:news/cubits/commentNewsCubit.dart';
import 'package:news/ui/widgets/SnackBarWidget.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/loginRequired.dart';

delAndReportReplyComm(
    {required CommentModel model, required BuildContext context, required TextEditingController reportC, required String newsId, required StateSetter setState, required int replyIndex}) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
            contentPadding: const EdgeInsets.all(20),
            elevation: 2.0,
            backgroundColor: UiUtils.getColorScheme(context).surface,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
            content: SingleChildScrollView(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (context.read<AuthCubit>().getUserId() == model.replyComList![replyIndex].userId!)
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      if (context.read<AuthCubit>().getUserId() != "0") {
                        context.read<DeleteCommCubit>().setDeleteComm(commId: model.replyComList![replyIndex].id!);
                      }
                    },
                    child: Row(
                      children: <Widget>[
                        CustomTextLabel(
                            text: 'deleteTxt',
                            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7), fontWeight: FontWeight.bold)),
                        const Spacer(),
                        BlocConsumer<DeleteCommCubit, DeleteCommState>(
                            bloc: context.read<DeleteCommCubit>(),
                            listener: (context, state) {
                              if (state is DeleteCommSuccess) {
                                context.read<CommentNewsCubit>().deleteCommentReply(model.id!, replyIndex);
                                showSnackBar(state.message, context);
                                Navigator.pop(context);
                              }
                            },
                            builder: (context, state) {
                              return SvgPicture.asset(UiUtils.getSvgImagePath("delete_icon"), color: UiUtils.getColorScheme(context).primaryContainer, height: 20, width: 20);
                            }),
                      ],
                    ),
                  ),
                if (context.read<AuthCubit>().getUserId() != model.replyComList![replyIndex].userId!)
                  Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Row(
                        children: <Widget>[
                          CustomTextLabel(
                              text: 'reportTxt',
                              textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7), fontWeight: FontWeight.bold)),
                          const Spacer(),
                          SvgPicture.asset(UiUtils.getSvgImagePath("flag_icon"), color: UiUtils.getColorScheme(context).primaryContainer, height: 20, width: 20)
                        ],
                      )),
                if (context.read<AuthCubit>().getUserId() != model.replyComList![replyIndex].userId!)
                  Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: TextField(
                        controller: reportC,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6)),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8), width: 0.5)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8), width: 0.5)),
                        ),
                      )),
                if (context.read<AuthCubit>().getUserId() != model.replyComList![replyIndex].userId!)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      CustomTextButton(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          textWidget: CustomTextLabel(
                              text: 'cancelBtn',
                              textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7), fontWeight: FontWeight.bold))),
                      BlocConsumer<SetFlagCubit, SetFlagState>(
                          bloc: context.read<SetFlagCubit>(),
                          listener: (context, state) {
                            if (state is SetFlagFetchSuccess) {
                              setState(() {
                                reportC.text = "";
                              });

                              showSnackBar(state.message, context);
                              Navigator.pop(context);
                            }
                          },
                          builder: (context, state) {
                            return CustomTextButton(
                                onTap: () {
                                  if (context.read<AuthCubit>().getUserId() != "0") {
                                    if (reportC.text.trim().isNotEmpty) {
                                      context.read<SetFlagCubit>().setFlag(commId: model.replyComList![replyIndex].id!, newsId: newsId, message: reportC.text);
                                    } else {
                                      showSnackBar(UiUtils.getTranslatedLabel(context, 'firstFillData'), context);
                                    }
                                  } else {
                                    loginRequired(context);
                                  }
                                },
                                textWidget: CustomTextLabel(
                                    text: 'submitBtn',
                                    textStyle:
                                        Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7), fontWeight: FontWeight.bold)));
                          })
                    ],
                  ),
              ],
            )));
      });
}
