/*
 * this is a test class
 */
class Version {
  int major;
  int minor;
  int service;
  String qualifier;
  
  Version.full(int this.major, int this.minor, int this.service, String this.qualifier);
  Version.part(major, minor, service):this.full(major, minor, service, null);
  
  String toString() {
    StringBuffer sb = new StringBuffer();
    sb..write(this.major)..write('.').
      ..write(this.minor)..write('.').
      ..write(service)..write('.').
      ..write(this.qualifier);
    return sb.toString(); 
  }
}
