import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrintPage extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  PrintPage(this.data);

  @override
  _PrintPageState createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  List<BluetoothDevice> _devices = [];
  String _devicesMsg = "";
  final f = NumberFormat("\$###,###.00", "en_US");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => {initPrinter()});
  }

  Future<void> initPrinter() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 2));

    if (!mounted) return;
    bluetoothPrint.scanResults.listen(
      (val) {
        if (!mounted) return;
        setState(() => {_devices = val});
        if (_devices.isEmpty)
          setState(() {
            _devicesMsg = "No Devices";
          });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(widget.data[0]['orderID']);
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Printer'),
        backgroundColor: Colors.redAccent,
      ),
      body: _devices.isEmpty
          ? Center(
              child: Text(_devicesMsg ?? ''),
            )
          : ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (c, i) {
                return ListTile(
                  leading: Icon(Icons.print),
                  title: Text(_devices[i].name!),
                  subtitle: Text(_devices[i].address!),
                  onTap: () {
                    _startPrint(_devices[i]);
                  },
                );
              },
            ),
    );
  }

  Future<void> _startPrint(BluetoothDevice device) async {
    if (device != null && device.address != null) {
      await bluetoothPrint.connect(device);

      Map<String, dynamic> config = Map();
      List<LineText> list = [];

      // Text('Name : ${doc['customerName']}'),
      // Text('College : ${doc['College']}'),
      // Text('Hostel : ${doc['Hostel']}'),
      // Text('Room : ${doc['Room']}'),
      // Text('Date Time : ${doc['DateTime']}'),
      // Text('Picked Time : ${doc['PickedTime']}'),
      // Text('Order: ${doc['productNames'].join(', ')}'),

      list.add(
        LineText(
          type: LineText.TYPE_TEXT,
          content: 'Order ID : ${widget.data[0]['orderID']}',
          weight: 2,
          width: 2,
          height: 2,
          align: LineText.ALIGN_CENTER,
          linefeed: 1,
        ),
      );
      list.add(
        LineText(
          type: LineText.TYPE_TEXT,
          content: 'Customer Name : ${widget.data[0]['customerName']}',
          weight: 2,
          width: 2,
          height: 2,
          align: LineText.ALIGN_CENTER,
          linefeed: 1,
        ),
      );
      list.add(
        LineText(
          type: LineText.TYPE_TEXT,
          content: 'College : ${widget.data[0]['College']}',
          weight: 2,
          width: 2,
          height: 2,
          align: LineText.ALIGN_CENTER,
          linefeed: 1,
        ),
      );
      list.add(
        LineText(
          type: LineText.TYPE_TEXT,
          content: 'Hostel : ${widget.data[0]['Hostel']}',
          weight: 2,
          width: 2,
          height: 2,
          align: LineText.ALIGN_CENTER,
          linefeed: 1,
        ),
      );
      list.add(
        LineText(
          type: LineText.TYPE_TEXT,
          content: 'Room : ${widget.data[0]['Room']}',
          weight: 2,
          width: 2,
          height: 2,
          align: LineText.ALIGN_CENTER,
          linefeed: 1,
        ),
      );
      list.add(
        LineText(
          type: LineText.TYPE_TEXT,
          content: 'Date & Time ${widget.data[0]['DateTime']}',
          weight: 2,
          width: 2,
          height: 2,
          align: LineText.ALIGN_CENTER,
          linefeed: 1,
        ),
      );
      list.add(
        LineText(
          type: LineText.TYPE_TEXT,
          content: 'Picked Time : ${widget.data[0]['PickedTime']}',
          weight: 2,
          width: 2,
          height: 2,
          align: LineText.ALIGN_CENTER,
          linefeed: 1,
        ),
      );
      list.add(
        LineText(
          type: LineText.TYPE_TEXT,
          content:
              'Product Names : ${widget.data[0]['productNames'].join(',')}',
          weight: 2,
          width: 2,
          height: 2,
          align: LineText.ALIGN_CENTER,
          linefeed: 1,
        ),
      );

      // for (var i = 0; i < widget.data.length; i++) {
      //   list.add(
      //     LineText(
      //       type: LineText.TYPE_TEXT,
      //       content: widget.data[i]['title'],
      //       weight: 0,
      //       align: LineText.ALIGN_LEFT,
      //       linefeed: 1,
      //     ),
      //   );
      //   list.add(
      //     LineText(
      //       type: LineText.TYPE_TEXT,
      //       content:
      //           "${f.format(this.widget.data[i]['price'])} x ${this.widget.data[i]['qty']}",
      //       align: LineText.ALIGN_LEFT,
      //       linefeed: 1,
      //     ),
      // );
      // }
    }
  }
}
