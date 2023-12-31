import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fitness_app/Helper/DBModels/exercise_model.dart';
import 'package:fitness_app/Utils/app_global.dart';
import 'package:fitness_app/constants/colors.dart';
import 'package:fitness_app/screens/account_screen/Workout/training_rest_popup.dart';
import 'package:fitness_app/screens/ads/AdmobHelper.dart';
import 'package:fitness_app/screens/rest_screen/ready_to_go.dart';
import 'package:fitness_app/screens/select_exercise/select_exercise.dart';
import 'package:fitness_app/widgets/color_remover.dart';
import 'package:fitness_app/widgets/cus_bottom_bar.dart';
import 'package:fitness_app/widgets/exercise_completed_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../Helper/DBModels/day_model.dart';
import '../../Utils/modal_progress_hud.dart';
import 'edit_plan.dart';
import 'HomePageBloc/home_bloc.dart';
import 'package:readmore/readmore.dart';


class OpenActivity extends StatefulWidget {

  DayModelLocalDB? dayModelLocalDB;
  OpenActivity({Key? key,this.dayModelLocalDB}) : super(key: key);

  @override
  State<OpenActivity> createState() => _OpenActivityState();
}

class _OpenActivityState extends State<OpenActivity> {
  bool? warmup_value = false;

  late HomeBloc _homeBloc;
  RequestExerciseData? exerciseData;

  final List<bool> _selectedPlan = <bool>[false, false, false];
  FlutterSecureStorage storage = const FlutterSecureStorage();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  int restresult = 10;
  double calories = 0;
  double totalTime = 0;

  String? _gifFilePath;
  Future<void> _loadGif() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      // Get file path of downloaded GIF image
      _gifFilePath = appDocDir.path;
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load GIF image.')),
      );
    }
  }
  // int pushUp = 10;
  // int plank = 15;

  void saveTrainingRest() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    restresult = pref.getInt('trainingrest')!;
    setState(() {

    });
  }

  Future <void> _navigaterest(BuildContext context) async {
    var _restresult1 = await showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: kColorFG,
        child: Container(
            height: MediaQuery.of(context).size.height*0.4,
            child: const TrainingRestPopup()
        ),
      ),
    );
    setState(() {
      restresult = _restresult1;
    });
    if (!mounted) return;
  }

  @override
  void initState() {
    super.initState();
    _homeBloc = BlocProvider.of<HomeBloc>(context);
    _homeBloc.add(GetAllExerciseOfDayEvent(day: widget.dayModelLocalDB!.name));

    analytics.setCurrentScreen(screenName: "Day Detail Screen");
    _loadGif();

    if(AppGlobal.selectedKneeIssueOption == "1"){
      _selectedPlan[0] = true;
      _selectedPlan[1] = false;
      _selectedPlan[2] = false;
    }
    else if(AppGlobal.selectedKneeIssueOption == "2"){
      _selectedPlan[0] = false;
      _selectedPlan[1] = true;
      _selectedPlan[2] = false;
    }
    else if(AppGlobal.selectedKneeIssueOption == "3"){
      _selectedPlan[0] = false;
      _selectedPlan[1] = false;
      _selectedPlan[2] = true;
    }
    else{
      _selectedPlan[0] = true;
      _selectedPlan[1] = false;
      _selectedPlan[2] = false;
    }
    // pushUp = int.parse(AppGlobal.selectedPushUpOption!);
    // print(AppGlobal.selectedPushUpOption);
    //
    // plank = int.parse(AppGlobal.selectedPlankOption!);
    // print(AppGlobal.selectedPlankOption);
    saveTrainingRest();
  }

  @override
  Widget build(BuildContext context) {

    return BlocConsumer<HomeBloc, HomeState>(listener: (context, state) {
      if (state is LoadingState) {
      } else if (state is ErrorState) {
        Fluttertoast.showToast(
            msg: state.error,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey.shade400,
            textColor: Colors.white,
            fontSize: 12.0);
      } else if (state is RefreshScreenState) {
      } else if (state is GetAllExerciseState) {
        exerciseData = state.exerciseData;
        calories = state.calories!;
        totalTime = state.totalTime!;
      }
    }, builder: (context, state) {
      return ModalProgressHUD(
        inAsyncCall: state is LoadingState,
        color: Colors.transparent,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: kColorBG,
            bottomNavigationBar: SizedBox(
              height: MediaQuery.of(context).size.height*0.07,
              width: AdmobHelper.getBannerAd().size.width.toDouble(),//double.infinity,
              child: AdWidget(
                ad:  AdmobHelper.getBannerAd()..load(),                 //myBanner..load(),
                key: UniqueKey(),
              ),
            ),
            // backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: kColorBG,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back)
              ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.dayModelLocalDB!.name,
                        style: const TextStyle(fontSize: 20.0,),
                      ),
                      // const Spacer(),
                      // const Icon(
                      //   Icons.control_point_duplicate_outlined,
                      //   color: Color(0xff1ce5c1),
                      // ),
                      // const SizedBox(
                      //   width: 12.0,
                      // ),
                    ],
                  ),
                  // const SizedBox(
                  //   height: .0,
                  // ),
                  // const Text(
                  //   "90 hours | Amenda Johnson",
                  //   style: TextStyle(
                  //     fontSize: 14.0,
                  //     color: Colors.grey,
                  //   ),
                  // ),
                ],
              ),
              // flexibleSpace: Container(
              //   decoration:  BoxDecoration(
              //     image: DecorationImage(
              //         image: AssetImage('assets/images/${widget.dayModelLocalDB!.image}'),
              //         fit: BoxFit.cover),
              //   ),
              // ),
            ),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1),
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            // backgroundColor: kColorBG,
                            isScrollControlled: true,
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(builder: (BuildContext context,
                                StateSetter setState /*You can rename this!*/) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 18, left: 18, right: 18),
                                    child: Container(
                                      height: MediaQuery.of(context).size.height * 0.7,
                                      child: Wrap(
                                        children: [
                                          const ListTile(
                                            title: Text(
                                              "Workout Settings",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
                                            ),
                                            subtitle: Text(
                                              "Choose workout based on your condition",
                                              style: TextStyle(fontSize: 13, color: Colors.white),
                                            ),
                                          ),
                                          Container(
                                            // height: MediaQuery.of(context).size.height * 0.38,
                                            width: MediaQuery.of(context).size.width,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              child: Column(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      setState(() {
                                                        _selectedPlan[2] = false;
                                                        _selectedPlan[1] = false;
                                                        _selectedPlan[0] = true;
                                                      });
                                                    },
                                                    child: Container(
                                                      margin: const EdgeInsets.all(12),
                                                      child: Container(
                                                        height: 9.h,
                                                        alignment: Alignment.bottomLeft,
                                                        padding: const EdgeInsets.only(left: 20.0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              'I\'m fine',
                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0,
                                                                color: _selectedPlan[0] == true
                                                                    ? Colors.black
                                                                    : Colors.white
                                                              ),
                                                            ),
                                                            Text(
                                                              'All workout are OK for me',
                                                              style: TextStyle(fontSize: 15.0,
                                                                color: _selectedPlan[0] == true
                                                                    ? Colors.black
                                                                    : Colors.white
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius.circular(35.0),
                                                          // image: DecorationImage(
                                                          //   image: AssetImage(
                                                          //       "assets/images/${constants.standard[index].image}"),
                                                          //   fit: BoxFit.cover,
                                                          // ),
                                                          gradient: LinearGradient(
                                                            // begin: Alignment.bottomCenter,
                                                            // end: Alignment.topCenter,
                                                            colors: [
                                                              _selectedPlan[0] == true
                                                                ? Colors.white60
                                                                : const Color(0xff1c1b20),
                                                              _selectedPlan[0] == true
                                                                  ? Colors.white
                                                                  : Colors.transparent,
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      setState(() {
                                                        _selectedPlan[0] = false;
                                                        _selectedPlan[2] = false;
                                                        _selectedPlan[1] = true;
                                                      });
                                                    },
                                                    child: Container(
                                                      margin: const EdgeInsets.only(left: 12, right: 12),
                                                      child: Container(
                                                        height: 9.h,
                                                        alignment: Alignment.bottomLeft,
                                                        padding: const EdgeInsets.only(left: 20.0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              'No jumping',
                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0,
                                                                color: _selectedPlan[1] == true
                                                                    ? Colors.black
                                                                    : Colors.white
                                                              ),
                                                            ),
                                                            Text(
                                                              'No noise, apartment friendly',
                                                              style: TextStyle(fontSize: 15.0,
                                                                color: _selectedPlan[1] == true
                                                                    ? Colors.black
                                                                    : Colors.white
                                                                      // : Colors.white
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(35.0),
                                                          // image: DecorationImage(
                                                          //   image: AssetImage(
                                                          //       "assets/images/${constants.standard[index].image}"),
                                                          //   fit: BoxFit.cover,
                                                          // ),
                                                          gradient: LinearGradient(
                                                            // begin: Alignment.b,
                                                            // end: Alignment.topCenter,
                                                            colors: [
                                                              _selectedPlan[1] == true
                                                                  ? Colors.white60
                                                                  : const Color(0xff1c1b20),
                                                              _selectedPlan[1] == true
                                                                  ? Colors.white
                                                                  : Colors.transparent,
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      setState(() {
                                                        _selectedPlan[0] = false;
                                                        _selectedPlan[1] = false;
                                                        _selectedPlan[2] = true;
                                                      });
                                                    },
                                                    child: Container(
                                                      margin: const EdgeInsets.all(12),
                                                      child: Container(
                                                        height: 9.h,
                                                        alignment: Alignment.bottomLeft,
                                                        padding: const EdgeInsets.only(left: 20.0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              'Low impact',
                                                              style: TextStyle(fontWeight: FontWeight.bold,
                                                                  fontSize: 20.0,
                                                                  color: _selectedPlan[2] == true
                                                                      ? Colors.black
                                                                      : Colors.white
                                                              ),
                                                            ),
                                                            Text(
                                                              'Friendly to overweight people',
                                                              style: TextStyle(
                                                                  fontSize: 15.0,
                                                                  color: _selectedPlan[2] == true
                                                                      ? Colors.black
                                                                      : Colors.white
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(35.0),
                                                          // image: DecorationImage(
                                                          //   image: AssetImage(
                                                          //       "assets/images/${constants.standard[index].image}"),
                                                          //   fit: BoxFit.cover,
                                                          // ),
                                                          gradient: LinearGradient(
                                                            // begin: Alignment.bottomCenter,
                                                            // end: Alignment.topCenter,
                                                            colors: [
                                                              _selectedPlan[2] == true
                                                                  ? Colors.white60
                                                                  : const Color(0xff1c1b20),
                                                                  // : const Color(0xff1c1b20),
                                                              _selectedPlan[2] == true
                                                                  ? Colors.white
                                                                  : Colors.transparent,
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Container(
                                                height: 1,
                                                color: Colors.white
                                            ),
                                          ),
                                          InkWell(
                                            onTap: (){
                                              _navigaterest(context).then((val){
                                                setState(() {
                                                  saveTrainingRest();
                                                });
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 10,bottom: 10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.restaurant, color: Colors.white, size: MediaQuery.of(context).size.width*0.065,
                                                      ),
                                                      SizedBox(width: MediaQuery.of(context).size.width*0.035),
                                                      Text(
                                                        "Training rest",
                                                        style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045, color: Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        '$restresult sec',
                                                        style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.043, color: kColorPrimary),
                                                      ),
                                                      Icon(
                                                          Icons.arrow_drop_down, color: kColorPrimary, size: MediaQuery.of(context).size.width*0.065
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10, top: 10),
                                            child: InkWell(
                                              onTap: () {
                                                if (_selectedPlan[0] == true && AppGlobal.selectedKneeIssueOption != "1"){
                                                  AppGlobal.selectedKneeIssueOption = "1";
                                                  AppGlobal.dataStoreFromConstantToLDB = "false";
                                                  _homeBloc.add(ClearExerciseEvent());
                                                  _homeBloc.add(RemoveDaysEvent());
                                                  Navigator.of(context).pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                          const CusBottomBar()),
                                                          (Route<dynamic> route) => false);
                                                }
                                                else if (_selectedPlan[1] == true && AppGlobal.selectedKneeIssueOption != "2"){
                                                  AppGlobal.selectedKneeIssueOption = "2";
                                                  AppGlobal.dataStoreFromConstantToLDB = "false";
                                                  _homeBloc.add(ClearExerciseEvent());
                                                  _homeBloc.add(RemoveDaysEvent());
                                                  Navigator.of(context).pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                          const CusBottomBar()),
                                                          (Route<dynamic> route) => false);
                                                }
                                                else if (_selectedPlan[2] == true && AppGlobal.selectedKneeIssueOption != "3"){
                                                  AppGlobal.selectedKneeIssueOption = "3";
                                                  AppGlobal.dataStoreFromConstantToLDB = "false";
                                                  _homeBloc.add(ClearExerciseEvent());
                                                  _homeBloc.add(RemoveDaysEvent());
                                                  Navigator.of(context).pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                          const CusBottomBar()),
                                                          (Route<dynamic> route) => false);
                                                }
                                                else{
                                                  Navigator.pop(context);
                                                }
                                              },
                                              child: Container(
                                                height: MediaQuery.of(context).size.height * 0.08,
                                                width: MediaQuery.of(context).size.width * 0.85,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius.circular(50),
                                                  color: kColorPrimary,
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    "Done",
                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                                                    //Icons.play_arrow,
                                                    //color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                              },
                            );
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.075,
                            width: MediaQuery.of(context).size.width * 0.15,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.white,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.settings,
                                color: kColorPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //SizedBox(width: MediaQuery.of(context).size.width*0.08),
                      InkWell(
                        onTap: () {
                          if(widget.dayModelLocalDB!.completedPercentage != 100 && widget.dayModelLocalDB!.exerciseNumInProgress < exerciseData!.exerciseList!.length) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) =>  ReadyToGo(exerciseData: exerciseData, dayModelLocalDB: widget.dayModelLocalDB,)));
                          } else {
                            showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * 0.3,
                                    child: const ExerciseCompletedPopup(),
                                  ),
                                ));
                          }

                          // Navigator.of(context).push(MaterialPageRoute(
                          //     builder: (ctx) =>  StartExercise(exerciseData: exerciseData, dayModelLocalDB: widget.dayModelLocalDB,)));
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.075,
                          width: MediaQuery.of(context).size.width * 0.7,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: widget.dayModelLocalDB!.completedPercentage != 100 && widget.dayModelLocalDB!.exerciseNumInProgress < (exerciseData !=null? exerciseData!.exerciseList!.length : int.parse('0'))? kColorPrimary: Colors.grey,
                          ),
                          child: const Center(
                            child: Text(
                              "GO!",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white),
                              //Icons.play_arrow,
                              //color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                // Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Checkbox(
                //         activeColor: kColorPrimary,
                //         value: warmup_value,
                //         onChanged: (value) {
                //           setState(() {
                //             warmup_value = value;
                //           });
                //         },
                //       ),
                //       Text(
                //         'Start with warm ups',
                //         style: TextStyle(fontWeight: FontWeight.bold),
                //       ),
                //     ],
                //   ),
                ],
            ),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(12.0),
                  right: Radius.circular(12.0),
                ),
                color: kColorBG,
                // color: Color(0xff1c1b20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Container(
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(12.0),
                    //     color: const Color(0xff38373a),
                    //   ),
                    //   child: const TabBar(
                    //     tabs: [
                    //       Tab(
                    //         text: ("Workouts"),
                    //       ),
                    //       Tab(
                    //         text: ("Trainer"),
                    //       ),
                    //     ],
                    //     indicatorColor: Colors.transparent,
                    //     labelColor: Color(0xff1ce5c1),
                    //     unselectedLabelColor: Colors.grey,
                    //     labelStyle: TextStyle(
                    //       fontSize: 18,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //     unselectedLabelStyle: TextStyle(
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: 18,
                    //     ),
                    //   ),
                    //   height: 60,
                    //   width: 240,
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Instruction",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        // InkWell(
                        //     onTap: (){
                        //
                        //     },
                        //     child: Icon(Icons.keyboard_arrow_down)
                        // )
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    ReadMoreText(
                      "Just ${AppGlobal.selectedPlan=='1'?'5-10':AppGlobal.selectedPlan=='2'?'10-20':AppGlobal.selectedPlan=='3'?'15-30':'a few'} min, this training is designed especially for beginners who want to lose weight but don't know where to start."
                      "\n\n"
                      "This training mixes with basic aerobic and anaerobic exercises. It uses your body weight to work all muscle groups and boost your fat burning."
                      "\n\n"
                      "Low-impact option is friendly for people who are overweight or have joint problems. Please stick to a low-calorie diet to maximize your workout result.",
                      trimLines: 2,
                      colorClickableText: kColorPrimary,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: 'Show more',
                      trimExpandedText: ' Show less',
                      moreStyle: const TextStyle(color:kColorPrimary ,fontWeight: FontWeight.bold),
                      lessStyle: const TextStyle(color:kColorPrimary ,fontWeight: FontWeight.bold),
                      textAlign: TextAlign.justify,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.035,
                          right: MediaQuery.of(context).size.width * 0.15
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppGlobal.selectedPlan=='1'?'Beginner':AppGlobal.selectedPlan=='2'?'Intermediate':AppGlobal.selectedPlan=='3'?'Advance':'Plan Name',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Level",
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "≈${calories.toStringAsFixed(1)}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Kcal",
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${totalTime.ceil()} mins",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Duration",
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Exercises ",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            Text(
                              "(${exerciseData!=null?exerciseData!.exerciseList!.length:'0'})",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(
                            //     content: Text('Coming Soon!'),
                            //     padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.35),
                            //   ),
                            // );

                            // showDialog(
                            //     context: context,
                            //     builder: (_) => Dialog(
                            //       child: Container(
                            //         height: MediaQuery.of(context).size.height * 0.3,
                            //         child: ComingSoonPopup(),
                            //       ),
                            //     ));
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      EditPlan(dayModelLocalDB: widget.dayModelLocalDB,exerciseData: exerciseData)
                              )
                            ).then((value) {
                              _homeBloc.add(GetAllExerciseOfDayEvent(day: widget.dayModelLocalDB!.name));
                            });
                          },
                          child: Row(
                            children: const [
                              Text(
                                "Edit ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.white),
                              ),
                              Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: //ColorRemover(
                      //child: TabBarView(children: [
                      ColorRemover(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: exerciseData != null
                            ? exerciseData!.exerciseList!.length
                            : 0,
                            itemBuilder: (ctx, index) {
                              return exerciseData!.exerciseList![index].dayTitle == widget.dayModelLocalDB!.name
                                ? InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (ctx) =>
                                           SelectExercise(exerciseModelLocalDB: exerciseData!.exerciseList![index], exerciseData: exerciseData,
                                             dayModelLocalDB: widget.dayModelLocalDB, current_index: index+1,
                                           )
                                      )
                                    );
                                },
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(8.0),
                                          child: Image(
                                              height: 70,
                                              width: 80,
                                              fit: BoxFit.cover,
                                              image: AssetImage(
                                                  "assets/images/${exerciseData!.exerciseList![index].exercise.image}")),
                                        ),
                                        // Image.file(
                                        //     File("$_gifFilePath/images/${exerciseData!.exerciseList![index].exercise.image}")
                                        // )
                                        const SizedBox(width: 18.0),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              exerciseData!.exerciseList![index].exercise.name,
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.width*0.04,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6.0,),
                                            Text(
                                              exerciseData!.exerciseList![index].exercise.type =='rap'
                                                  ?
                                              "${exerciseData!.exerciseList![index].raps} reps"
                                                  :
                                              "${exerciseData!.exerciseList![index].time} sec",
                                              // exerciseData!.exerciseList![index].exercise!.type =='rap'
                                              //     ?
                                              // exerciseData!.exerciseList![index].exercise!.name=='PUSH-UPS'
                                              //     ?
                                              //   "$pushUp raps" : "${exerciseData!.exerciseList![index].raps} raps"
                                              //     :
                                              // exerciseData!.exerciseList![index].exercise!.name=='PLANK'
                                              //     ?
                                              // "$plank secs" : "${exerciseData!.exerciseList![index].time} sec",
                                              style: const TextStyle(fontSize: 12,),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              )
                                  : const SizedBox();
                            }),
                      ),
                      // ColorRemover(
                      //   child: ListView.builder(
                      //       physics: const BouncingScrollPhysics(),
                      //       itemCount: constants.chat.length,
                      //       itemBuilder: (ctx, index) {
                      //         return GestureDetector(
                      //           onTap: () {
                      //             Navigator.of(context).push(MaterialPageRoute(
                      //                 builder: (ctx) =>
                      //                     const SelectExercise()));
                      //           },
                      //           child: Padding(
                      //             padding: const EdgeInsets.all(18.0),
                      //             child: Row(
                      //               children: [
                      //                 ClipRRect(
                      //                   borderRadius:
                      //                       BorderRadius.circular(8.0),
                      //                   child: Image(
                      //                       height: 80,
                      //                       width: 90,
                      //                       fit: BoxFit.cover,
                      //                       image: AssetImage(
                      //                           "assets/images/${constants.chat[index].image}")),
                      //                 ),
                      //                 const SizedBox(
                      //                   width: 18.0,
                      //                 ),
                      //                 Column(
                      //                   crossAxisAlignment:
                      //                       CrossAxisAlignment.start,
                      //                   children: [
                      //                     Text(
                      //                       constants.chat[index].name,
                      //                       style: const TextStyle(
                      //                         fontSize: 20,
                      //                         fontWeight: FontWeight.bold,
                      //                       ),
                      //                     ),
                      //                     const SizedBox(
                      //                       height: 6.0,
                      //                     ),
                      //                     const Text(
                      //                       "Trainer",
                      //                       style: TextStyle(
                      //                         fontSize: 12,
                      //                       ),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         );
                      //       }),
                      // ),
                      // ]),
                      //),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.085),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}