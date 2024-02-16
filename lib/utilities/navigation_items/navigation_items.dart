import 'package:adams_county_scheduler/logical_interface/cubit/home_navigation/home_navigation_cubit.dart';
import 'package:adams_county_scheduler/user_interface/account/account_page.dart';
import 'package:adams_county_scheduler/user_interface/admin/admin_page.dart';
import 'package:adams_county_scheduler/user_interface/careers/careers_page.dart';
import 'package:adams_county_scheduler/user_interface/scheduler/scheduler_page.dart';
import 'package:adams_county_scheduler/user_interface/schools/schools_page.dart';
import 'package:adams_county_scheduler/user_interface/students/students_page.dart';
import 'package:collapsible_sidebar/collapsible_sidebar.dart';
import 'package:flutter/material.dart';

import '../../objects/profile.dart';

List<CollapsibleItem> getNavigationItems(
    {required Profile? currentUser,
    required HomeNavigationState navigationState,
    required Function(int index) updateIndex,}) {
  List<CollapsibleItem> items = [
    CollapsibleItem(
      isSelected: navigationState.selectedIndex == 0,
      text: 'Schools',
      icon: Icons.school_outlined,
      onPressed: () {
        updateIndex(0);
      },
    ),
    CollapsibleItem(
      isSelected: navigationState.selectedIndex == 1,
      text: 'Careers',
      icon: Icons.work_outline_sharp,
      onPressed: () {
        updateIndex(1);
      },
    ),
    CollapsibleItem(
      isSelected: navigationState.selectedIndex == 2,
      text: 'Students',
      icon: Icons.people_outline,
      onPressed: () {
        updateIndex(2);
      },
    ),
    CollapsibleItem(
      isSelected: navigationState.selectedIndex == 3,
      text: 'Scheduler',
      icon: Icons.schedule,
      onPressed: () {
        updateIndex(3);
      },
    ),
    CollapsibleItem(
      isSelected: navigationState.selectedIndex == 4,
      text: 'Account',
      icon: Icons.person_2_outlined,
      onPressed: () {
        updateIndex(4);
      },
    ),

  ];

  if (currentUser?.isAdmin ?? false) {
    items.add(
      CollapsibleItem(
        text: 'Admin',
        icon: Icons.admin_panel_settings_outlined,
        onPressed: () {
          updateIndex(items.length);
        },
      ),
    );
  }

  return items;
}

IndexedStack homePages = const IndexedStack(
  children: [
    SchoolsPage(),
    CareersPage(),
    StudentsPage(),
    SchedulerPage(),
    AccountPage(),
    AdminPage(),
  ],
);
