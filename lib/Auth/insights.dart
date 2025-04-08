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
    selectedWeek = "Whole Month";

    // Preload data for the Weekly tab when the page is first loaded
    fetchMessages();
    fetchMessageStats(); // Preload stats data
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
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

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

          // Ensure endDate does not exceed the month's last day
          if (weekEndDate.isAfter(DateTime(now.year, now.month + 1, 0))) {
            weekEndDate = DateTime(now.year, now.month + 1, 0);
          }

          startDate = weekStartDate;
          endDate = weekEndDate;
        }
      } else if (selectedIndex == 2) {
        // Yearly tab: Fetch messages for the selected month or the whole year
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
          SizedBox(height: 27),
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
                    buildMessageStatsCard("weekly"),
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
            child: DropdownButton<String>(
              value: selectedWeek,
              onChanged: (String? newValue) {
                setState(() {
                  selectedWeek = newValue;
                });
                fetchMessages();
              },
              items: [
                DropdownMenuItem<String>(
                  value: "Whole Month",
                  child: Text("Whole Month"),
                ),
                ...weeksInMonth.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ],
              isExpanded: true,
              underline: Container(height: 1, color: Colors.grey),
            ),
          ),
          SizedBox(height: 20),
          noMessagesReceived
              ? Text(
                  "No messages received in this period",
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
                    buildMessageStatsCard("monthly"),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<int>(
              value: selectedMonth,
              onChanged: (int? newValue) {
                setState(() {
                  selectedMonth = newValue!;
                });
                fetchMessages(); // Fetch messages based on the selected month
              },
              items: months.asMap().entries.map<DropdownMenuItem<int>>((entry) {
                int index = entry.key;
                String value = entry.value;
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(value),
                );
              }).toList(),
              isExpanded: true,
              underline: Container(height: 1, color: Colors.grey),
            ),
          ),
          SizedBox(height: 8),
          noMessagesReceived
              ? Text(
                  "No messages received in this period",
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
                    buildMessageStatsCard("yearly"),
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

  Widget buildMessageStatsCard(String period) {
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
              "Message Statistics",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Messages:",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "$AllTotalMessages",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Spam Messages:",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "$AllSpamMessages",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              "This represents the total detection messages received across all users and how many of them were detected as spam.",
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  /*Widget buildWeeklyUsageChart(int spamMessages, int legitMessages) {
    DateTime now = DateTime.now();
    DateTime startDate =
        now.subtract(Duration(days: now.weekday - 1)); // Start from Monday
    DateTime endDate = startDate.add(Duration(days: 6)); // End on Sunday

    print(
        "Building Weekly Chart: Start Date = $startDate, End Date = $endDate");

    // Generate the date labels for the week (Mon-Sun)
    List<String> dateLabels = [];
    for (int i = 0; i < 7; i++) {
      DateTime date = startDate.add(Duration(days: i));
      String dateStr = DateFormat('MMM dd').format(date);
      dateLabels.add(dateStr);
    }

    // Initialize counters for each day of the week
    List<int> spamCountPerDay = List.filled(7, 0); // Spam counts for each day
    List<int> legitCountPerDay = List.filled(7, 0); // Legit counts for each day

    // StreamBuilder to fetch messages from Firebase
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("messages")
          .where("timestamp",
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where("timestamp", isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        // Initialize counters for spam and legit messages per day
        Map<String, int> spamCounts = {};
        Map<String, int> legitCounts = {};

        // Initialize counters for each day of the week
        for (int i = 0; i < 7; i++) {
          DateTime date = startDate.add(Duration(days: i));
          String dateStr = DateFormat('MMM dd').format(date);
          spamCounts[dateStr] = 0;
          legitCounts[dateStr] = 0;
        }

        // Create a set to track processed timestamps for uniqueness
        Set<String> processedMessages = {};

        // Iterate over the documents to correctly count spam and legit messages per day
        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>;
          DateTime timestamp = (data["timestamp"] as Timestamp).toDate();
          String dateStr = DateFormat('MMM dd').format(timestamp);

          // Ensure we're only processing messages for the current week
          if (timestamp.isAfter(startDate) && timestamp.isBefore(endDate)) {
            String label = (data["label"] ?? "").toString().toLowerCase();
            String messageId = doc.id; // Unique message identifier

            // Check if the message has already been processed (same message for the same day)
            if (!processedMessages.contains(messageId)) {
              // Mark message as processed by adding its ID
              processedMessages.add(messageId);

              // Increment counts based on the label
              if (label == "spam" && spamCounts.containsKey(dateStr)) {
                spamCounts[dateStr] = (spamCounts[dateStr] ?? 0) + 1;
              } else if (label == "not spam" &&
                  legitCounts.containsKey(dateStr)) {
                legitCounts[dateStr] = (legitCounts[dateStr] ?? 0) + 1;
              }

              print(
                  "Date: $dateStr | Label: $label | Spam Count: ${spamCounts[dateStr]} | Legit Count: ${legitCounts[dateStr]}");
            }
          }
        }

        // Build the spots for the line chart based on updated counts
        List<FlSpot> spamSpots = [];
        List<FlSpot> legitSpots = [];

        for (int i = 0; i < dateLabels.length; i++) {
          String date = dateLabels[i];
          spamSpots.add(FlSpot(i.toDouble(), spamCounts[date]!.toDouble()));
          legitSpots.add(FlSpot(i.toDouble(), legitCounts[date]!.toDouble()));
        }

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
                  "Weekly AI Fraud Detector Usage Pattern",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Container(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Text(value.toInt().toString(),
                                  style: TextStyle(fontSize: 12));
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < dateLabels.length) {
                                return Text(dateLabels[index],
                                    style: TextStyle(fontSize: 10));
                              }
                              return Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spamSpots,
                          isCurved: true,
                          color: Colors.redAccent,
                          barWidth: 3,
                          belowBarData: BarAreaData(show: false),
                        ),
                        LineChartBarData(
                          spots: legitSpots,
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 3,
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "This chart shows your weekly usage pattern of the AI fraud detector. "
                  "Red represents spam detections, and green represents legitimate messages analyzed.",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildMonthlyUsagePatternChart() {
    DateTime startDate =
        DateTime(DateTime.now().year, DateTime.now().month, 1).toLocal();

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("messages")
          .where("timestamp",
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        Map<String, int> legitCounts = {};
        Map<String, int> spamCounts = {};
        Map<String, int> totalCounts = {};

        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>;
          DateTime timestamp = (data["timestamp"] as Timestamp).toDate();
          String date = DateFormat('yyyy-MM-dd').format(timestamp);

          String weekKey = 'Week ${getWeekNumber(timestamp)}';

          if (!totalCounts.containsKey(weekKey)) {
            totalCounts[weekKey] = 0;
            spamCounts[weekKey] = 0;
            legitCounts[weekKey] = 0;
          }

          totalCounts[weekKey] = (totalCounts[weekKey]! + 1);
          if (data["label"] == "Spam") {
            spamCounts[weekKey] = (spamCounts[weekKey]! + 1);
          } else {
            legitCounts[weekKey] = (legitCounts[weekKey]! + 1);
          }
        }

        List<String> sortedWeeks = totalCounts.keys.toList()..sort();
        List<FlSpot> legitSpots = [];
        List<FlSpot> spamSpots = [];
        List<FlSpot> totalSpots = [];

        for (int i = 0; i < sortedWeeks.length; i++) {
          String week = sortedWeeks[i];
          legitSpots.add(FlSpot(i.toDouble(), legitCounts[week]!.toDouble()));
          spamSpots.add(FlSpot(i.toDouble(), spamCounts[week]!.toDouble()));
          totalSpots.add(FlSpot(i.toDouble(), totalCounts[week]!.toDouble()));
        }

        return buildChartContainer(
          chartTitle: "Monthly Usage Pattern",
          legitSpots: legitSpots,
          spamSpots: spamSpots,
          totalSpots: totalSpots,
          sortedDates: sortedWeeks,
        );
      },
    );
  }

  Widget buildYearlyUsagePatternChart() {
    DateTime startDate = DateTime(DateTime.now().year, 1, 1).toLocal();

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("messages")
          .where("timestamp",
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        Map<String, int> legitCounts = {};
        Map<String, int> spamCounts = {};
        Map<String, int> totalCounts = {};

        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>;
          DateTime timestamp = (data["timestamp"] as Timestamp).toDate();
          String month = DateFormat('MMMM').format(timestamp);

          if (!totalCounts.containsKey(month)) {
            totalCounts[month] = 0;
            spamCounts[month] = 0;
            legitCounts[month] = 0;
          }

          totalCounts[month] = (totalCounts[month]! + 1);
          if (data["label"] == "Spam") {
            spamCounts[month] = (spamCounts[month]! + 1);
          } else {
            legitCounts[month] = (legitCounts[month]! + 1);
          }
        }

        List<String> sortedMonths = totalCounts.keys.toList()..sort();
        List<FlSpot> legitSpots = [];
        List<FlSpot> spamSpots = [];
        List<FlSpot> totalSpots = [];

        for (int i = 0; i < sortedMonths.length; i++) {
          String month = sortedMonths[i];
          legitSpots.add(FlSpot(i.toDouble(), legitCounts[month]!.toDouble()));
          spamSpots.add(FlSpot(i.toDouble(), spamCounts[month]!.toDouble()));
          totalSpots.add(FlSpot(i.toDouble(), totalCounts[month]!.toDouble()));
        }

        return buildChartContainer(
          chartTitle: "Yearly Usage Pattern",
          legitSpots: legitSpots,
          spamSpots: spamSpots,
          totalSpots: totalSpots,
          sortedDates: sortedMonths,
        );
      },
    );
  }

  Widget buildChartContainer({
    required String chartTitle,
    required List<FlSpot> legitSpots,
    required List<FlSpot> spamSpots,
    required List<FlSpot> totalSpots,
    required List<String> sortedDates,
  }) {
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
              chartTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(),
                              style: TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          return index < sortedDates.length
                              ? Text(sortedDates[index].substring(5),
                                  style: TextStyle(fontSize: 10))
                              : Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: legitSpots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: spamSpots,
                      isCurved: true,
                      color: Colors.redAccent,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: totalSpots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "This chart tracks your AI fraud detector usage over time. Green indicates legit messages, red indicates spam messages, and blue shows total messages analyzed.",
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }*/
}
