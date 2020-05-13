//import 'package:flutter/material.dart';
/*class MyToggleButton extends StatelessWidget {
  List<bool> selections =  List.generate(2, (index) => false);
  String feed;
  MyToggleButton(this.feed);


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        child: Container(
          child: ToggleButtons(
            onPressed: (int index) async {
                selections[index] =! selections[index];
                if(index ==1){
                  feed = "locations";
                }else if (index == 2){
                  feed = "kalmanLocations";
                }


            },

            borderRadius: BorderRadius.circular(30),
            selectedColor: Colors.green,
            color: Colors.blueAccent,
            fillColor: Colors.black38,
            isSelected: selections,
            children: <Widget>[
              Icon(Icons.gps_fixed),
              Icon(Icons.gps_not_fixed),
            ],),
        ),
      ),
    );
  }
}
*/
