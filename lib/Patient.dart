class Patient{

  final String name;
  final String dob;
  final String medName;
  final String medDose;
  final String medQuan;
  final String medExp;
  final String add;
  final String doctor = "#533 Dr. LEE SAM";

  const Patient(this.name, this.dob, this.medName, this.medDose, this. medQuan, this.medExp, this.add);
}

class Rx{
  final String name;
  final String dob;
  final String medName;
  final String medDose;
  final String medQuan;
  final DateTime issuedOn;
  final DateTime expireBy;
  final String add;
  final String doctor = "#533 Dr. LEE SAM";
  final String dsign;

  const Rx(this.name, this.dob, this.medName, this.medDose, this. medQuan, this.issuedOn, this.expireBy, this.add, this.dsign);
}