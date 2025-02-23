import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class insights extends StatefulWidget {
  const insights({super.key});

  @override
  State<insights> createState() => _insightsState();
}

class _insightsState extends State<insights>
    with SingleTickerProviderStateMixin {
  @override
  late TabController _tabController;
  int selectedIndex = 0;
  final List<String> options = ["Weekly", "Monthly", "Yearly"];

  int totalMessages = 0;
  int legitMessages = 0;
  int spamMessages = 0;
  int reportedSpamMessages = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedIndex = _tabController.index;
      });
      fetchMessages(); // This will now only be called after _tabController is initialized
    });
    // Load data after the tab controller is initialized
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      DateTime now = DateTime.now();
      DateTime startDate = getStartDate(selectedIndex, now);

      // Fetch classified messages (Legit & Spam)
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("messages")
          .where("userId", isEqualTo: user.uid)
          .where("timestamp", isGreaterThanOrEqualTo: startDate)
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

      // Fetch the number of spam messages the user has reported
      QuerySnapshot reportedQuery = await FirebaseFirestore.instance
          .collection("reportedMessagesSummary")
          .where("reportedUsers",
              arrayContains: user.uid) // Check if user reported
          .get();

      int reportedCount = reportedQuery.docs.length;

      setState(() {
        totalMessages = total;
        legitMessages = legit;
        spamMessages = spam;
        reportedSpamMessages = reportedCount; // Store the reported count
      });
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  DateTime getStartDate(int index, DateTime now) {
    if (index == 0) {
      return now.subtract(Duration(days: 7)); // Weekly
    } else if (index == 1) {
      return DateTime(now.year, now.month, 1); // Monthly
    } else {
      return DateTime(now.year, 1, 1); // Yearly
    }
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
                      labelColor: Colors.black,
                      indicatorColor: Colors.blue,
                      labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold), // Selected tab text size
                      unselectedLabelStyle:
                          TextStyle(fontSize: 14), // Unselected tab text size
                      indicatorSize:
                          TabBarIndicatorSize.label, // Controls indicator width
                      tabs: [
                        Tab(text: "Weekly"),
                        Tab(text: "Monthly"),
                        Tab(text: "Yearly"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
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
      ),
    );
  }

  // Weekly Tab with Stats and Chart
  Widget WeeklyTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 8),
          _buildChart(),
          _buildStats(),
          buildReportedMessages(),
        ],
      ),
    );
  }

  // Monthly Tab with Stats and Chart
  Widget MonthlyTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 8),
          //  _buildChart(),
          _buildStats(),
        ],
      ),
    );
  }

  // Yearly Tab with Stats and Chart
  Widget YearlyTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 8),
          // _buildChart(),
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildStats() {
    double legitPercentage =
        totalMessages > 0 ? (legitMessages / totalMessages) * 100 : 0;
    double spamPercentage =
        totalMessages > 0 ? (spamMessages / totalMessages) * 100 : 0;

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

            // Total Messages Display
            Center(
              child: Column(
                children: [
                  Text(
                    "$totalMessages",
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

            // Legitimate and Spam Breakdown
            _buildCategoryRow(
                "Legitimate", legitMessages, legitPercentage, Colors.green),
            _buildCategoryRow(
                "Spam", spamMessages, spamPercentage, Color(0xFF2184FC)),
          ],
        ),
      ),
    );
  }

// Helper Widget for Category Row
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
                      color: Color(0xFF2184FC),
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

  Widget buildReportedMessages() {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            Container(
              height: 200, // Adjust chart height
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY:
                              reportedSpamMessages.toDouble(), // Reported count
                          color: Colors.redAccent,
                          width: 15,
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text("Spam Reported",
                              style: TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Total Spam Messages Reported: $reportedSpamMessages",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
