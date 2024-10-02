class PagedData<T> {
  String field='';
  List<T> list=[];
  int pageIndex=0;
  int pageSize=10;
  bool hasMore=true;
  bool isloading=false;
  int count=0;

  reset(){
    pageIndex=1;
    list=[];
    count=0;
  }
  init(){
     hasMore=true;
     isloading=true;
  }
}

class EditableGrid {
  bool isEdit=false;
  bool isDelete=false;
  bool isNew=false;
  bool isLoading=false;

}