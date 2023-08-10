// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/categoryCubit.dart';
import 'package:news/data/models/CategoryModel.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:news/utils/uiUtils.dart';

import '../../app/routes.dart';
import '../../cubits/appLocalizationCubit.dart';
import '../widgets/circularProgressIndicator.dart';
import '../widgets/customAppBar.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  CategoryScreenState createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> {
  late final ScrollController _categoryScrollController = ScrollController()..addListener(hasMoreCategoryScrollListener);

  void getCategory() {
    Future.delayed(Duration.zero, () {
      context.read<CategoryCubit>().getCategory(context: context, langId: context.read<AppLocalizationCubit>().state.id);
    });
  }

  @override
  void initState() {
    getCategory();
    super.initState();
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  void hasMoreCategoryScrollListener() {
    if (_categoryScrollController.offset >= _categoryScrollController.position.maxScrollExtent && !_categoryScrollController.position.outOfRange) {
      if (context.read<CategoryCubit>().hasMoreCategory()) {
        context.read<CategoryCubit>().getMoreCategory(context: context, langId: context.read<AppLocalizationCubit>().state.id);
      } else {
        debugPrint("No more categories");
      }
    }
  }

  Widget _buildCategory() {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        if (state is CategoryFetchSuccess) {
          return RefreshIndicator(
              onRefresh: () async {
                context.read<CategoryCubit>().getCategory(context: context, langId: context.read<AppLocalizationCubit>().state.id);
              },
              child: GridView.count(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.only(top: 45, bottom: MediaQuery.of(context).size.height / 10.0, left: 10, right: 10),
                crossAxisCount: 3,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 30.0,
                shrinkWrap: true,
                controller: _categoryScrollController,
                children: List.generate(state.category.length, (index) {
                  return _buildCategoryContainer(
                    category: state.category[index],
                    hasMore: state.hasMore,
                    hasMoreCategoryFetchError: state.hasMoreFetchError,
                    index: index,
                    totalCurrentCategory: state.category.length,
                  );
                }),
              ));
        }
        if (state is CategoryFetchFailure) {
          return const Center(
              child: CustomTextLabel(
            text: 'catNotAvail',
            textAlign: TextAlign.center,
          ));
        }
        return const SizedBox.shrink();
      },
    );
  }

  _buildCategoryContainer({
    required CategoryModel category,
    required int index,
    required int totalCurrentCategory,
    required bool hasMoreCategoryFetchError,
    required bool hasMore,
  }) {
    if (index == totalCurrentCategory - 1) {
      //check if hasMore
      if (hasMore) {
        if (hasMoreCategoryFetchError) {
          return const SizedBox.shrink();
        } else {
          return Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0), child: showCircularProgress(true, Theme.of(context).primaryColor)));
        }
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.subCat, arguments: {"catId": category.id, "catName": category.categoryName});
      },
      child: Column(
        children: [
          Expanded(
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 45,
              child: ClipRRect(borderRadius: BorderRadius.circular(50.0), child: CustomNetworkImage(networkImageUrl: category.image!, height: 90, isVideo: false, width: 90, fit: BoxFit.cover)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              category.categoryName!,
              style: TextStyle(fontSize: 16, color: UiUtils.getColorScheme(context).primaryContainer),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: setCustomAppBar(height: 45, isBackBtn: false, label: 'categoryLbl', context: context, isConvertText: true),
      body: _buildCategory(),
    );
  }
}
