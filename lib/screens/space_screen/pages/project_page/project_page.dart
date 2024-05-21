import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:unityspace/models/project_models.dart';
import 'package:unityspace/store/project_store.dart';
import 'package:unityspace/utils/constants.dart';
import 'package:unityspace/utils/errors.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:unityspace/utils/logger_plugin.dart';
import 'package:wstore/wstore.dart';

class ProjectsPageStore extends WStore {
  ProjectErrors error = ProjectErrors.none;
  WStoreStatus status = WStoreStatus.init;
  ProjectStore projectStore;

  ProjectsPageStore({ProjectStore? projectStore})
      : projectStore = projectStore ?? ProjectStore();

  Future<void> loadData(int spaceId) async {
    if (status == WStoreStatus.loading) return;
    setStore(() {
      status = WStoreStatus.loading;
      error = ProjectErrors.none;
    });
    try {
      await projectStore.getProjectsData(spaceId);
      setStore(() {
        status = WStoreStatus.loaded;
      });
    } catch (e, stack) {
      logger.d('on ProjectsPage'
          'ProjectsStore loadData error=$e\nstack=$stack');
      setStore(() {
        status = WStoreStatus.error;
        error = ProjectErrors.loadingDataError;
      });
    }
  }

  List<Project> get projects => computedFromStore(
        store: projectStore,
        getValue: (store) => store.projects,
        keyName: 'projects',
      );

  @override
  ProjectsPage get widget => super.widget as ProjectsPage;
}

class ProjectsPage extends WStoreWidget<ProjectsPageStore> {
  final int spaceId;

  const ProjectsPage({
    super.key,
    required this.spaceId,
  });

  @override
  ProjectsPageStore createWStore() => ProjectsPageStore()..loadData(spaceId);

  @override
  Widget build(BuildContext context, ProjectsPageStore store) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreStatusBuilder(
      store: store,
      watch: (store) => store.status,
      builderError: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            switch (store.error) {
              ProjectErrors.none => "",
              ProjectErrors.loadingDataError =>
                localization.problem_uploading_data_try_again
            },
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF111012).withOpacity(0.8),
              fontSize: 20,
              height: 1.2,
            ),
          ),
        );
      },
      builderLoading: (context) {
        return Center(
          child: Lottie.asset(
            ConstantIcons.mainLoader,
            width: 200,
            height: 200,
          ),
        );
      },
      builder: (context, _) {
        return const SizedBox.shrink();
      },
      builderLoaded: (BuildContext context) {
        return WStoreBuilder<ProjectsPageStore>(
            watch: (store) => [store.projects],
            store: context.wstore<ProjectsPageStore>(),
            builder: (context, store) {
              return ListView.builder(
                  itemCount: store.projects.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(child: Text('${store.projects[index].name}'));
                  });
            });
      },
    );
  }
}
