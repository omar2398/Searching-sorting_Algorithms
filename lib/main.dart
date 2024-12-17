library mainlib;
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sorting and Searching Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  List<int> _numbers = [];
  StreamController<List<int>> _streamController = StreamController.broadcast();
  String _currentSearchAlgo = 'binary';
  bool isSearching = false;
  int _searchTarget = 0;
  int _currentIndex = -1;
  String _currentSortAlgo = 'bubble';
  double _sampleSize = 320;
  bool isSorted = false;
  bool isSorting = false;
  int speed = 0;
  static int duration = 1500;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? _tabController;
  List<int> myList = [];

  Duration _getDuration() {
    return Duration(microseconds: duration);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateRandomNumbers();
    for (int i = 1; i <= 500; i++) {
      myList.add(i);
    }
  }

  @override
  void dispose() {
    _streamController.close();
    _tabController?.dispose();
    super.dispose();
  }

  void _generateRandomNumbers([int count = 50]) {
    _numbers = List.generate(count, (index) => Random().nextInt(100));
    _streamController.add(_numbers);
  }

  Future<void> _linearSearch(int target) async {
    setState(() {
      isSearching = true;
      _currentIndex = -1;
    });

    for (int i = 0; i < myList.length; i++) {
      setState(() {
        _currentIndex = i;
      });

      await Future.delayed(Duration(milliseconds: 300));

      if (myList[i] == target) {
        setState(() {
          isSearching = false;
        });
        return;
      }
    }

    setState(() {
      isSearching = false;
    });
  }

  Future<void> _binarySearch(int target) async {
    List<int> sortedNumbers = myList;
    _streamController.add(sortedNumbers);

    int left = 0, right = sortedNumbers.length - 1;

    setState(() {
      isSearching = true;
      _currentIndex = -1;
    });

    while (left <= right) {
      int mid = left + (right - left) ~/ 2;
      setState(() {
        _currentIndex = mid;
      });

      await Future.delayed(const Duration(milliseconds: 300));

      if (sortedNumbers[mid] == target) {
        setState(() {
          isSearching = false;
        });
        return;
      } else if (sortedNumbers[mid] < target) {
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }

    setState(() {
      isSearching = false;
    });
  }

  Future<void> _hashTableSearch(int target) async {
    setState(() {
      isSearching = true;
      _currentIndex = -1;
    });

    Map<int, int> hashTable = {};
    await Future.delayed(const Duration(milliseconds: 300));
    for (int i = 0; i < myList.length; i++) {
      hashTable[myList[i]] = i;
    }

    if (hashTable.containsKey(target)) {
      setState(() {
        _currentIndex = hashTable[target]!;
        isSearching = false;
      });
    } else {
      setState(() {
        isSearching = false;
      });
    }
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sampleSize = MediaQuery.of(context).size.width / 2;
    for (int i = 0; i < _sampleSize; ++i) {
      _numbers.add(Random().nextInt(500));
    }
    setState(() {});
  }

  _bubbleSort() async {
    for (int i = 0; i < _numbers.length; ++i) {
      for (int j = 0; j < _numbers.length - i - 1; ++j) {
        if (_numbers[j] > _numbers[j + 1]) {
          int temp = _numbers[j];
          _numbers[j] = _numbers[j + 1];
          _numbers[j + 1] = temp;
        }

        await Future.delayed(_getDuration(), () {});

        _streamController.add(_numbers);
      }
    }
  }

  _heapSort() async {

    heapify(List<int> arr, int n, int i) async {
      int largest = i;
      int l = 2 * i + 1;
      int r = 2 * i + 2;

      if (l < n && arr[l] > arr[largest]) largest = l;

      if (r < n && arr[r] > arr[largest]) largest = r;

      if (largest != i) {
        int temp = _numbers[i];
        _numbers[i] = _numbers[largest];
        _numbers[largest] = temp;
        heapify(arr, n, largest);
      }
      await Future.delayed(_getDuration());
    }

    for (int i = _numbers.length ~/ 2; i >= 0; i--) {
      await heapify(_numbers, _numbers.length, i);
      _streamController.add(_numbers);
    }
    for (int i = _numbers.length - 1; i >= 0; i--) {
      int temp = _numbers[0];
      _numbers[0] = _numbers[i];
      _numbers[i] = temp;
      await heapify(_numbers, i, 0);
      _streamController.add(_numbers);
    }

  }

  _radixSort() async {
    int getMax(List<int> arr) {
      int max = arr[0];
      for (int i = 1; i < arr.length; i++) {
        if (arr[i] > max) max = arr[i];
      }
      return max;
    }
    countingSort(List<int> arr, int exp) async {
      int n = arr.length;
      List<int> output = List.filled(n, 0);
      List<int> count = List.filled(10, 0);
      for (int i = 0; i < n; i++) {
        int digit = (arr[i] ~/ exp) % 10;
        count[digit]++;
      }
      for (int i = 1; i < 10; i++) {
        count[i] += count[i - 1];
      }
      for (int i = n - 1; i >= 0; i--) {
        int digit = (arr[i] ~/ exp) % 10;
        output[count[digit] - 1] = arr[i];
        count[digit]--;
      }
      for (int i = 0; i < n; i++) {
        arr[i] = output[i];
        _streamController.add(List.from(arr));
        await Future.delayed(_getDuration());
      }
    }

     radixSort(List<int> arr) async {
      int max = getMax(arr);
      for (int exp = 1; max ~/ exp > 0; exp *= 10) {
        await countingSort(arr, exp);
      }
    }

    await radixSort(_numbers);
  }

  _mergeSort(int leftIndex, int rightIndex) async {
    Future<void> merge(int leftIndex, int middleIndex, int rightIndex) async {
      int leftSize = middleIndex - leftIndex + 1;
      int rightSize = rightIndex - middleIndex;

      List leftList = List.filled(leftSize, null, growable: false);
      List rightList = List.filled(rightSize, null, growable: false);

      for (int i = 0; i < leftSize; i++) leftList[i] = _numbers[leftIndex + i];
      for (int j = 0; j < rightSize; j++) rightList[j] = _numbers[middleIndex + j + 1];

      int i = 0, j = 0;
      int k = leftIndex;

      while (i < leftSize && j < rightSize) {
        if (leftList[i] <= rightList[j]) {
          _numbers[k] = leftList[i];
          i++;
        } else {
          _numbers[k] = rightList[j];
          j++;
        }

        await Future.delayed(_getDuration(), () {});
        _streamController.add(_numbers);

        k++;
      }

      while (i < leftSize) {
        _numbers[k] = leftList[i];
        i++;
        k++;

        await Future.delayed(_getDuration(), () {});
        _streamController.add(_numbers);
      }

      while (j < rightSize) {
        _numbers[k] = rightList[j];
        j++;
        k++;

        await Future.delayed(_getDuration(), () {});
        _streamController.add(_numbers);
      }
    }

    if (leftIndex < rightIndex) {
      int middleIndex = (rightIndex + leftIndex) ~/ 2;

      await _mergeSort(leftIndex, middleIndex);
      await _mergeSort(middleIndex + 1, rightIndex);

      await Future.delayed(_getDuration(), () {});

      _streamController.add(_numbers);

      await merge(leftIndex, middleIndex, rightIndex);
    }
  }

  _reset() {
    isSorted = false;
    _numbers = [];
    for (int i = 0; i < _sampleSize; ++i) {
      _numbers.add(Random().nextInt(500));
    }
    _streamController.add(_numbers);
  }

  _setSortAlgo(String type) {
    setState(() {
      _currentSortAlgo = type;
    });
  }

  _checkAndResetIfSorted() async {
    if (isSorted) {
      _reset();
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  _sort() async {
    setState(() {
      isSorting = true;
    });

    await _checkAndResetIfSorted();

    Stopwatch stopwatch = new Stopwatch()..start();

    switch (_currentSortAlgo) {
      case "bubble":
        await _bubbleSort();
        break;
      case "heap":
        await _heapSort();
        break;
      case "merge":
        await _mergeSort(0, _sampleSize.toInt() - 1);
        break;
        case "redix":
        await _radixSort();
        break;
    }

    stopwatch.stop();

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "completed",
        ),
      ),
    );
    setState(() {
      isSorting = false;
      isSorted = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          indicatorColor: Colors.blue,
          controller: _tabController,
          labelColor: Colors.blue,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(
            fontSize: 17,
          ),
          tabs: const [
            Tab(text: 'Sorting'),
            Tab(text: 'Searching'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSortingTab(),
          _buildSearchingTab(),
        ],
      ),
    );
  }

  Widget _buildSearchingTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 45,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(5.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(5.5),
                      ),
                      prefixIcon: const Icon(Icons.numbers, color: Colors.blue),
                      hintText: "Target",
                      hintStyle: const TextStyle(color: Colors.blue, height: 1),
                      filled: true,
                      fillColor: Colors.blue[50],
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _searchTarget = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(5.5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton<String>(
                    value: _currentSearchAlgo,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(20),
                    items: const [
                      DropdownMenuItem(value: 'linear', child: Text('Linear Search')),
                      DropdownMenuItem(value: 'binary', child: Text('Binary Search')),
                      DropdownMenuItem(value: 'hash', child: Text('Hash Table Search')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _currentSearchAlgo = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(5.5),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.5),
                      ),
                    ),
                    onPressed: isSearching
                        ? null
                        : () {
                      if (_currentSearchAlgo == 'linear') {
                        _linearSearch(_searchTarget);
                      } else if (_currentSearchAlgo == 'binary') {
                        _binarySearch(_searchTarget);
                      } else if (_currentSearchAlgo == 'hash') {
                        _hashTableSearch(_searchTarget);
                      }
                    },
                    child: const Text('Search', style: TextStyle(color: Colors.blue)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<int>>(
            stream: _streamController.stream,
            builder: (context, snapshot) {
              List<int> numbers = snapshot.data ?? [];
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 13,
                  childAspectRatio: 2.0,
                  crossAxisSpacing: 1.5,
                  mainAxisSpacing: 3.0,
                ),
                itemCount: numbers.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: index == _currentIndex
                        ? Colors.red
                        : Colors.blue[200],
                    alignment: Alignment.center,
                    child: Text(
                      numbers[index].toString(),
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSortingTab() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(5.5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: DropdownButton<String>(
                    value: _currentSortAlgo,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(20),
                    items: const [
                      DropdownMenuItem(value: 'bubble', child: Text('Bubble Sort')),
                      DropdownMenuItem(value: 'heap', child: Text('Heap Sort')),
                      DropdownMenuItem(value: 'merge', child: Text('Merge Sort')),
                      DropdownMenuItem(value: 'redix', child: Text('Redix Sort')),
                    ],
                    onChanged: (value) {
                      _reset();
                      _setSortAlgo(value!);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(top: 5),
          child: StreamBuilder<Object>(
              initialData: _numbers,
              stream: _streamController.stream,
              builder: (context, snapshot) {
                List<int> numbers = snapshot.data as List<int>;
                int counter = 0;
                return Row(
                  children: numbers.map((int num) {
                    counter++;
                    return CustomPaint(
                      painter: BarPainter(index: counter, value: num, width: MediaQuery.of(context).size.width / _sampleSize),
                    );
                  }).toList(),
                );
              }),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(5.5),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.5),
                    ),
                  ),
                  onPressed: isSorting
                      ? null
                      : () {
                    _reset();
                    _setSortAlgo(_currentSortAlgo);
                  },
                  child: const Text(
                    "RESET",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(5.5),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.5),
                    ),
                  ),
                  onPressed: isSorting ? null : _sort,
                  child: const Text(
                    "SORT",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class BarPainter extends CustomPainter {
  final double width;
  final int value;
  final int index;

  BarPainter({required this.width, required this.value, required this.index});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    if (this.value < 500 * .10) {
      paint.color = Color(0xFFE3F2FD);
    } else if (this.value < 500 * .20) {
      paint.color = Color(0xFFBBDEFB);
    } else if (this.value < 500 * .30) {
      paint.color = Color(0xFF90CAF9);
    } else if (this.value < 500 * .40) {
      paint.color = Color(0xFF64B5F6);
    } else if (this.value < 500 * .50) {
      paint.color = Color(0xFF42A5F5);
    } else if (this.value < 500 * .60) {
      paint.color = Color(0xFF2196F3);
    } else if (this.value < 500 * .70) {
      paint.color = Color(0xFF1E88E5);
    } else if (this.value < 500 * .80) {
      paint.color = Color(0xFF1976D2);
    } else if (this.value < 500 * .90) {
      paint.color = Color(0xFF1565C0);
    } else {
      paint.color = Color(0xFF0D47A1);
    }

  paint.strokeWidth = width;
    paint.strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(index * width, 0), Offset(index * width, value.ceilToDouble()), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }}
