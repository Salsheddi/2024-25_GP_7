import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class insights extends StatefulWidget {
  const insights({super.key});

  @override
  State<insights> createState() => _insightsState();
}

class _insightsState extends State<insights>
    with SingleTickerProviderStateMixin {
  @override
  late TabController _tabController;
  int _currentIndex = 1;
  bool _isNavBarVisible = true;
  int selectedIndex = 0;
  String selectedPeriod = "Weekly";
  final List<String> options = ["Weekly", "Monthly", "Yearly"];
  bool isLoading = false;

  int totalMessages = 0;
  int AllTotalMessages = 0;
  int legitMessages = 0;
  int spamMessages = 0;
  int AllSpamMessages = 0;
  int reportedSpamMessages = 0;
  bool noMessagesReceived = false;

  List<String> weeksInMonth = [];
  String? selectedWeek;

  int selectedWeekIndex = 0;
  int selectedMonthIndex = DateTime.now().month;

  int selectedMonth = 0; // 0 = Whole Year, 1-12 = specific months
  final List<String> months = [
    "Whole Year",
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: 0); // Set default tab to Weekly
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          selectedIndex = _tabController.index;
        });
        fetchMessages();
        fetchMessageStats(); // Ensure stats are fetched on tab change
      }
    });

    generateWeeks();
    selectedWeekIndex = getCurrentWeekIndex(); // Set current week as default
    selectedWeek = weeksInMonth[selectedWeekIndex];

    // Preload data for the Weekly tab when the page is first loaded
    fetchMessages();
    fetchMessageStats(); // Preload stats data
  }

  int getCurrentWeekIndex() {
    DateTime now = DateTime.now();
    for (int i = 0; i < weeksInMonth.length; i++) {
      String week = weeksInMonth[i];
      final regex = RegExp(r"\((\d+)-(\d+)\)");
      final match = regex.firstMatch(week);
      if (match != null) {
        int startDay = int.parse(match.group(1)!);
        int endDay = int.parse(match.group(2)!);
        if (now.day >= startDay && now.day <= endDay) {
          return i;
        }
      }
    }
    return 0;
  }

  void generateWeeks() {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    List<String> weeks = [];
    DateTime currentStart = firstDayOfMonth;

    while (currentStart.isBefore(lastDayOfMonth)) {
      DateTime currentEnd = currentStart.add(Duration(days: 6));

      if (currentEnd.isAfter(lastDayOfMonth)) {
        currentEnd = lastDayOfMonth;
      }

      weeks.add(
          "Week ${weeks.length + 1} (${currentStart.day}-${currentEnd.day})");
      currentStart = currentEnd.add(Duration(days: 1));
    }

    setState(() {
      weeksInMonth = weeks;
      selectedWeek = weeks.isNotEmpty ? weeks[0] : null;
    });
  }

  DateTime getWeekStartDate(int weekNumber) {
    DateTime firstDayOfMonth =
        DateTime(DateTime.now().year, DateTime.now().month, 1);

    DateTime start = firstDayOfMonth.add(Duration(days: (weekNumber - 1) * 7));

    // Ensure start date is within the month
    if (start.month != firstDayOfMonth.month) {
      start = firstDayOfMonth;
    }

    return start;
  }

  Future<void> fetchMessages() async {
    setState(() => isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      DateTime now = DateTime.now();
      DateTime startDate = DateTime.now(); // Initialize startDate
      DateTime endDate = DateTime.now(); // Initialize endDate

      if (selectedIndex == 0) {
        // Weekly tab
        if (selectedWeekIndex >= 0 && selectedWeekIndex < weeksInMonth.length) {
          String selected = weeksInMonth[selectedWeekIndex];
          final regex = RegExp(r"\((\d+)-(\d+)\)");
          final match = regex.firstMatch(selected);
          if (match != null) {
            int startDay = int.parse(match.group(1)!);
            int endDay = int.parse(match.group(2)!);
            startDate = DateTime(now.year, now.month, startDay);
            endDate = DateTime(now.year, now.month, endDay);
          }
        }
      } else if (selectedIndex == 1) {
        // Monthly tab
        int selectedMonth = selectedMonthIndex;
        if (selectedMonth >= 1 && selectedMonth <= 12) {
          startDate = DateTime(now.year, selectedMonth, 1);
          endDate = DateTime(now.year, selectedMonth + 1, 0); // end of month
        }
      } else if (selectedIndex == 2) {
        // Yearly tab
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31);
      }

      Timestamp startTimestamp = Timestamp.fromDate(startDate);
      Timestamp endTimestamp = Timestamp.fromDate(endDate);

      print("Selected Week: $selectedWeek");
      print("Fetching messages from: $startDate to $endDate");

      // Query messages based on the selected period (week, month, or year)
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("messages")
          .where("userId", isEqualTo: user.uid)
          .where("timestamp", isGreaterThanOrEqualTo: startTimestamp)
          .where("timestamp", isLessThanOrEqualTo: endTimestamp)
          .get();

      int total = querySnapshot.docs.length;
      int legit = 0;
      int spam = 0;
      Set<String> reportedSpamMessageIds =
          Set(); // To track reported spam messages

      for (var doc in querySnapshot.docs) {
        String label = doc["label"];
        print("Fetched message: ${doc.id}, Label: $label");

        if (label == "Not Spam") {
          legit++;
        } else if (label == "Spam") {
          spam++;

          // Check if the message has been reported by the user
          QuerySnapshot reportedQuery = await FirebaseFirestore.instance
              .collection("reportedMessagesSummary")
              .where("messageContent",
                  isEqualTo:
                      doc["message"]) // Check for matching message content
              .where("reportedUsers",
                  arrayContains: user
                      .uid) // Check if the current user is in the reportedUsers array
              .get();

          if (reportedQuery.docs.isNotEmpty) {
            // Mark this spam message as reported by the user
            reportedSpamMessageIds.add(doc.id);
          }
        }
      }

      int reportedSpamCount = reportedSpamMessageIds.length;

      print("Fetched ${querySnapshot.docs.length} documents");
      print(
          "Total Spam Messages: $spam, Reported Spam Messages: $reportedSpamCount");

      // Handle reported messages
      setState(() {
        totalMessages = total;
        legitMessages = legit;
        spamMessages = spam;
        reportedSpamMessages = reportedSpamCount;
        noMessagesReceived = totalMessages == 0;
      });
    } catch (e) {
      print("Error fetching messages: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchMessageStats() async {
    try {
      DateTime now = DateTime.now();
      DateTime startDate = DateTime.now(); // Initialize startDate
      DateTime endDate = DateTime.now(); // Initialize endDate

      if (selectedIndex == 0) {
        // Weekly tab: Fetch messages for the current week
        startDate =
            now.subtract(Duration(days: now.weekday - 1)); // Start of the week
        endDate = startDate.add(Duration(days: 6)); // End of the week
      } else if (selectedIndex == 1) {
        // Monthly tab
        if (selectedWeek == "Whole Month") {
          startDate = DateTime(now.year, now.month, 1);
          endDate = DateTime(now.year, now.month + 1, 0);
        } else {
          int weekNumber = weeksInMonth.indexOf(selectedWeek!) + 1;
          DateTime weekStartDate = getWeekStartDate(weekNumber);
          DateTime weekEndDate = weekStartDate.add(Duration(days: 6));

          if (weekEndDate.isAfter(DateTime(now.year, now.month + 1, 0))) {
            weekEndDate = DateTime(now.year, now.month + 1, 0);
          }

          startDate = weekStartDate;
          endDate = weekEndDate;
        }
      } else if (selectedIndex == 2) {
        // Yearly tab
        if (selectedMonth == 0) {
          // Whole Year
          startDate = DateTime(now.year, 1, 1);
          endDate = DateTime(now.year, 12, 31);
        } else {
          // Specific Month
          startDate = DateTime(now.year, selectedMonth, 1);
          endDate = DateTime(now.year, selectedMonth + 1, 0);
        }
      }

      // Debugging: Print the date range for the Yearly tab
      print("Start Date: $startDate, End Date: $endDate");

      // Convert to timestamps for Firestore query
      Timestamp startTimestamp = Timestamp.fromDate(startDate);
      Timestamp endTimestamp = Timestamp.fromDate(endDate);

      // Fetch messages based on the selected period (week, month, or year)
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("messages")
          .where("timestamp", isGreaterThanOrEqualTo: startTimestamp)
          .where("timestamp", isLessThanOrEqualTo: endTimestamp)
          .get();

      int total = querySnapshot.docs.length;
      int legit = 0;
      int spam = 0;

      for (var doc in querySnapshot.docs) {
        String label = doc["label"];
        if (label == "Not Spam") {
          legit++;
        } else if (label == "Spam") {
          spam++;
        }
      }

      setState(() {
        AllTotalMessages = total;
        AllSpamMessages = spam;
        noMessagesReceived = total == 0;
      });
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  DateTime getStartDate(int index, DateTime now) {
    if (index == 0) {
      // Weekly: Start from the beginning of the current week (Sunday)
      return now.subtract(Duration(
          days: now.weekday - 1)); // Adjust this to the start of the week
    } else if (index == 1) {
      // Monthly: Start from the first day of the current month
      return DateTime(now.year, now.month, 1); // First day of the current month
    } else if (index == 2) {
      // Yearly: Start from the first day of the current year
      return DateTime(now.year, 1, 1); // First day of the current year
    } else {
      return now; // Default: Return current date (handle as fallback)
    }
  }

  int getWeekNumber(DateTime date) {
    // The DateTime class uses Monday as the first day of the week by default
    DateTime firstDayOfYear = DateTime(date.year, 1, 1);
    int days = date.difference(firstDayOfYear).inDays;
    int weekNumber = ((days / 7).floor()) + 1;
    return weekNumber;
  }

  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3, // Adjust based on the number of tabs
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                color: const Color(0xFF2184FC).withOpacity(0.76),
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 63.0, left: 16.0, right: 16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Message Insights",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 115.0),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40)),
                    color: Color(0xFFF7F6F6),
                  ),
                  height: double.infinity,
                  width: double.infinity,
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.black,
                        indicatorColor: Colors.blue,
                        labelStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        unselectedLabelStyle: TextStyle(fontSize: 14),
                        indicatorSize: TabBarIndicatorSize.label,
                        tabs: [
                          Tab(text: "Weekly"),
                          Tab(text: "Monthly"),
                          Tab(text: "Yearly"),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            WeeklyTab(),
                            MonthlyTab(),
                            YearlyTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2184FC), // Customize this color
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Bottom Navigation Bar
          bottomNavigationBar: Visibility(
            visible: _isNavBarVisible,
            child: CurvedNavigationBar(
              backgroundColor: const Color(0xFFF7F6F6),
              height: 70,
              color: const Color(0xFF2184FC).withOpacity(0.65),
              animationDuration: const Duration(milliseconds: 350),
              index: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                Icon(Icons.smart_toy_outlined, size: 32, color: Colors.white),
                Icon(Icons.home, size: 32, color: Colors.white),
                Icon(Icons.person, size: 32, color: Colors.white),
              ],
            ),
          ),
        ));
  }

  Widget WeeklyTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: weeksInMonth[selectedWeekIndex],
              onChanged: (String? newValue) {
                setState(() {
                  selectedWeekIndex = weeksInMonth.indexOf(newValue!);
                  selectedWeek = newValue;
                });
                fetchMessages();
              },
              items: weeksInMonth.map((week) {
                return DropdownMenuItem<String>(
                  value: week,
                  child: Text(week),
                );
              }).toList(),
              isExpanded: true,
              underline: Container(height: 1, color: Colors.grey),
            ),
          ),
          SizedBox(height: 16),
          noMessagesReceived
              ? Text(
                  "No messages received in this week",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[600]),
                )
              : Column(
                  children: [
                    _buildChart(),
                    _buildStats(),
                    buildReportedMessagess(),
                    SizedBox(height: 20),
                  ],
                ),
        ],
      ),
    );
  }

  Widget MonthlyTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<int>(
              value: selectedMonthIndex,
              onChanged: (int? newValue) {
                setState(() {
                  selectedMonthIndex = newValue!;
                });
                fetchMessages();
              },
              items: months
                  .asMap()
                  .entries
                  .where((e) => e.key != 0) // Skip "Whole Year"
                  .map((entry) => DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text(entry.value),
                      ))
                  .toList(),
              isExpanded: true,
              underline: Container(height: 1, color: Colors.grey),
            ),
          ),
          SizedBox(height: 16),
          noMessagesReceived
              ? Text(
                  "No messages received in this month",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[600]),
                )
              : Column(
                  children: [
                    _buildChart(),
                    _buildStats(),
                    buildReportedMessagess(),
                    SizedBox(height: 20),
                  ],
                ),
        ],
      ),
    );
  }

  Widget YearlyTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          noMessagesReceived
              ? Text(
                  "No messages received in this year",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[600]),
                )
              : Column(
                  children: [
                    _buildChart(),
                    _buildStats(),
                    buildReportedMessagess(),
                    SizedBox(height: 20),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Messages Classification",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: legitMessages.toDouble(),
                      color: Colors.green,
                      title: '${legitMessages.toString()}',
                      radius: 60,
                      titleStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: spamMessages.toDouble(),
                      color: Colors.red[700],
                      title: '${spamMessages.toString()}',
                      radius: 60,
                      titleStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    int displayedTotalMessages = legitMessages +
        spamMessages; // Ensure only classified messages are counted

    double legitPercentage = displayedTotalMessages > 0
        ? (legitMessages / displayedTotalMessages) * 100
        : 0;
    double spamPercentage = displayedTotalMessages > 0
        ? (spamMessages / displayedTotalMessages) * 100
        : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Messages Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    "$displayedTotalMessages",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Total Messages",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Divider(thickness: 1, color: Colors.grey.shade300),
            _buildCategoryRow(
                "Legitimate", legitMessages, legitPercentage, Colors.green),
            _buildCategoryRow(
                "Spam", spamMessages, spamPercentage, Color(0xFFD32F2F)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(
      String label, int count, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 18),
            ),
          ),
          Text(
            "${percentage.toStringAsFixed(1)}%",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildReportedMessagess() {
    // Calculate the report ratio
    double reportRatio = spamMessages > 0
        ? (reportedSpamMessages > 0 ? reportedSpamMessages / spamMessages : 0)
        : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reported Messages",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: reportRatio,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2184FC)),
              minHeight: 15,
              borderRadius: BorderRadius.circular(10),
            ),
            SizedBox(height: 10),
            Text(
              "Reported Spam: $reportedSpamMessages / $spamMessages",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              "The progress bar shows the proportion of spam messages you have reported. "
              "A higher filled portion means more spam reports.",
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
