// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
contract MyContract{
    uint requestId;
    
    struct Transaction{
        uint timestamp;
    }
    struct request{
        uint unitId;
        string items;
        string quantity;
        string status;
        string unit_email;
        string[] tracking;
        uint[] trackingTimeStamp;
        string Acceptedby;
        Transaction tx;
        
    }

    struct ADST{
        address add;
        uint[] reqId;   
        string ourDDST;
        uint[] acceptedRequest;
    }

    struct DDST{
        address  add;
        mapping(uint=>request) ReqDDST;
        uint[] receivedId;
        uint[] DDSTtoUnits; 
        uint[] DDSTtoASC;
        string[] units;
        string ourDGST;
        uint[] Accepted;
        uint[] AcceptedDGSTRequest; 
    }
    struct DGST{
        mapping(uint=>request) ReqDDST;
        uint[] receivedId;
        uint[] DGSTtoDivisions; 
        uint[] DGSTtoManufacturer;
        string[] Divisions;
        uint[] Accepted;
        
    }

    mapping(uint=>request) ReqMap;
    mapping(string=>ADST)  mADST;
    mapping(string=>DDST)  mDDST;
    mapping(string=>DGST)  mDGST;
    
    function addADST(string memory userId,string memory _ourDDST)public{
        
         
         mADST[userId].ourDDST=_ourDDST;
         mDDST[_ourDDST].units.push(userId);

     }
     function addDDST(string memory userId,string memory _ourDGST)public{
   
         mDDST[userId].ourDGST=_ourDGST;
         mDGST[_ourDGST].Divisions.push(userId);
     }


     function getADSTrequest(string memory _items,string memory _quantity,string memory _email)public{
        
         ReqMap[requestId].items=_items;
         ReqMap[requestId].quantity=_quantity;
         ReqMap[requestId].unit_email=_email;
         ReqMap[requestId].status="pending";
         ReqMap[requestId].tracking.push("sent to DDST");
         mADST[_email].reqId.push(requestId);
         ReqMap[requestId].tx.timestamp=block.timestamp;
         ReqMap[requestId].trackingTimeStamp.push(block.timestamp);
         requestId++;

     }


     function getAccepted(string memory _email)public view returns(string[][3] memory,uint[] memory,uint[] memory ,string[] memory){
         uint i;
         uint k=mADST[_email].reqId.length;
         string[] memory Rarr=new string[](k);
         string[] memory Qarr=new string[](k);
         uint[] memory Idarr=new uint[](k);
         uint[] memory Timestamps=new uint[](k);
         string[] memory Status=new string[](k);
         string[] memory Acceptedby=new string[](k);
          for(i=0;i<k;i++){
            if(keccak256(abi.encodePacked("accepted")) == keccak256(abi.encodePacked(ReqMap[mADST[_email].reqId[i]].status))){
                    Rarr[i]=ReqMap[mADST[_email].reqId[i]].items;
                    Acceptedby[i]=ReqMap[mADST[_email].reqId[i]].Acceptedby;
                    Qarr[i]=ReqMap[mADST[_email].reqId[i]].quantity;
                    Status[i]=ReqMap[mADST[_email].reqId[i]].status;
                    Idarr[i]=mADST[_email].reqId[i];
                    Timestamps[i]=ReqMap[mADST[_email].reqId[i]].tx.timestamp;
            }
         }
         
         return ([Rarr,Qarr,Status],Idarr,Timestamps,Acceptedby);
     }


          function getPending(string memory _email)public view returns(string[][3] memory,uint[] memory,uint[] memory){
         uint i;
         uint k=mADST[_email].reqId.length;
         string[] memory Rarr=new string[](k);
         string[] memory Qarr=new string[](k);
         uint[] memory Idarr=new uint[](k);
         uint[] memory Timestamps=new uint[](k);
         string[] memory Status=new string[](k);
         for(i=0;i<k;i++){
            if(keccak256(abi.encodePacked("pending")) == keccak256(abi.encodePacked(ReqMap[mADST[_email].reqId[i]].status))){
                    Rarr[i]=ReqMap[mADST[_email].reqId[i]].items;
                    Qarr[i]=ReqMap[mADST[_email].reqId[i]].quantity;
                    Status[i]=ReqMap[mADST[_email].reqId[i]].status;
                    Timestamps[i]=ReqMap[mADST[_email].reqId[i]].tx.timestamp;
                    Idarr[i]=mADST[_email].reqId[i];
            }
         }
         
         return ([Rarr,Qarr,Status],Idarr,Timestamps);
     }


     function sendToUnits(uint id,string memory ddst_email)public{
         
         ReqMap[id].tracking.push(string.concat("sent to Units from Division :",ddst_email));
         ReqMap[id].trackingTimeStamp.push(block.timestamp);

         mDDST[ddst_email].DDSTtoUnits.push(id);
     }

     function getSentToUnits(string memory _ddstemail)public view returns(uint[] memory ){
         return mDDST[_ddstemail].DDSTtoUnits;
     }


    


     function getADSTs_underMe(string memory ddst_email)public view returns(string[] memory){
         return mDDST[ddst_email].units;
     }


     function myDDST(string memory _email)public view returns(string memory,uint[] memory){
         return (mADST[_email].ourDDST,mADST[_email].reqId);
     }


     function getDetailsById(uint id)public view returns(string memory,string memory,string memory,string memory,uint,string memory){
         return (ReqMap[id].items,ReqMap[id].quantity,ReqMap[id].status,ReqMap[id].unit_email,ReqMap[id].tx.timestamp,ReqMap[id].Acceptedby);
     }
     function updateStatus(uint id,string memory ddst_email,string memory email)public {
         
         ReqMap[id].status="accepted";
         ReqMap[id].tracking.push(string.concat("Accepted by :",email));
         ReqMap[id].Acceptedby=email;
         ReqMap[id].trackingTimeStamp.push(block.timestamp);
         mADST[email].acceptedRequest.push(id);
         uint i;
         bool flag;
         for(i=0;i<mDDST[ddst_email].DDSTtoUnits.length;i++){
             if(mDDST[ddst_email].DDSTtoUnits[i]==id){
                 mDDST[ddst_email].DDSTtoUnits[i]=mDDST[ddst_email].DDSTtoUnits[mDDST[ddst_email].DDSTtoUnits.length-1];
                 mDDST[ddst_email].DDSTtoUnits[mDDST[ddst_email].DDSTtoUnits.length-1]=id;
                 mDDST[ddst_email].DDSTtoUnits.pop();
                 break;
             }
         }
         
         for (i=0; i < mDGST[mDDST[ddst_email].ourDGST].DGSTtoDivisions.length; i++) {
            if (id == mDGST[mDDST[ddst_email].ourDGST].DGSTtoDivisions[i]) {
                flag = true;

                break;
            }
        }
        if(flag==true){
            mDDST[ddst_email].AcceptedDGSTRequest.push(id);
            for(i=0;i<mDGST[mDDST[ddst_email].ourDGST].DGSTtoDivisions[i];i++){
             if(mDDST[ddst_email].DDSTtoASC[i]==id){

                 
                 mDGST[mDDST[ddst_email].ourDGST].DGSTtoDivisions[i]=mDGST[mDDST[ddst_email].ourDGST].DGSTtoDivisions[mDGST[mDDST[ddst_email].ourDGST].DGSTtoDivisions.length-1];
                 mDGST[mDDST[ddst_email].ourDGST].DGSTtoDivisions[mDGST[mDDST[ddst_email].ourDGST].DGSTtoDivisions.length-1]=id;
                 mDGST[mDDST[ddst_email].ourDGST].DGSTtoDivisions.pop();
                 break;
             }
         }
         for(i=0;i<mDDST[mADST[ReqMap[id].unit_email].ourDDST].DDSTtoASC.length;i++){
             if(mDDST[mADST[ReqMap[id].unit_email].ourDDST].DDSTtoASC[i]==id){
                 mDDST[mADST[ReqMap[id].unit_email].ourDDST].DDSTtoASC[i]=mDDST[mADST[ReqMap[id].unit_email].ourDDST].DDSTtoASC[mDDST[mADST[ReqMap[id].unit_email].ourDDST].DDSTtoASC.length-1];
                mDDST[mADST[ReqMap[id].unit_email].ourDDST].DDSTtoASC[mDDST[mADST[ReqMap[id].unit_email].ourDDST].DDSTtoASC.length-1]=id;
                mDDST[mADST[ReqMap[id].unit_email].ourDDST].DDSTtoASC.pop();
             }

         }
         mDDST[mADST[ReqMap[id].unit_email].ourDDST].Accepted.push(id);
         mDGST[mDDST[mADST[ReqMap[id].unit_email].ourDDST].ourDGST].Accepted.push(id);
        }

        else{
            mDDST[ddst_email].Accepted.push(id);

        }
        
         
     }
     function DDSTgetAccepted(string memory DDST_mail)public view returns(uint[] memory){
         return mDDST[DDST_mail].Accepted;

     }

     function AcceptedbyRequest(string memory email)public view returns(uint[] memory){
         return mADST[email].acceptedRequest;
     }
     function getTracking(uint id)public view returns(string memory,string[] memory,uint[] memory){
        return (ReqMap[id].status,ReqMap[id].tracking,ReqMap[id].trackingTimeStamp);
     }
     //DGST
     function sendtoASC(uint id,string memory ddst_email)public{
         
         ReqMap[id].tracking.push(string.concat("sent to DGST from Division :",ddst_email));
           ReqMap[id].trackingTimeStamp.push(block.timestamp);
         mDDST[ddst_email].DDSTtoASC.push(id);
         for(uint i=0;i<mDDST[ddst_email].DDSTtoUnits.length;i++){
             if(mDDST[ddst_email].DDSTtoUnits[i]==id){
                 mDDST[ddst_email].DDSTtoUnits[i]=mDDST[ddst_email].DDSTtoUnits[mDDST[ddst_email].DDSTtoUnits.length-1];
                 mDDST[ddst_email].DDSTtoUnits.pop();
             }
         }

     }
      function getSentToASC(string memory _ddstemail)public view returns(uint[] memory  ){
          
         return mDDST[_ddstemail].DDSTtoASC;
     }
     function getDDSTs_underMe(string memory dgst_email)public view returns(string[] memory){
         return mDGST[dgst_email].Divisions;
     }

     function getAcceptedDDST(string memory _email)public view returns(string[][3] memory,uint[] memory,uint[] memory,string[]  memory){
         uint i;
         uint k=mDDST[_email].Accepted.length;
         string[] memory Rarr=new string[](k);
         string[] memory Qarr=new string[](k);
         uint[] memory Timestamps=new uint[](k);
         string[] memory Acceptedby=new string[](k);
         uint[] memory Idarr=new uint[](k);
         string[] memory Status=new string[](k);
        
         for(i=0;i<k;i++){
            
                    Rarr[i]=ReqMap[mDDST[_email].Accepted[i]].items;
                    Qarr[i]=ReqMap[mDDST[_email].Accepted[i]].quantity;
                    Status[i]=ReqMap[mDDST[_email].Accepted[i]].status;
                    Timestamps[i]=ReqMap[mDDST[_email].Accepted[i]].tx.timestamp;
                    Acceptedby[i]=ReqMap[mDDST[_email].Accepted[i]].Acceptedby;
                    Idarr[i]=mDDST[_email].Accepted[i];
            
         }
         
         return ([Rarr,Qarr,Status],Idarr,Timestamps,Acceptedby);
     }


          
     function grtPendingDDST(string memory _email)public view returns(string[][3] memory,uint[] memory,uint[] memory,string[] memory ){
         uint i;
         uint k=mDDST[_email].DDSTtoASC.length;
         string[] memory Rarr=new string[](k);
         string[] memory Qarr=new string[](k);
         uint[] memory Timestamps=new uint[](k);
         uint[] memory Idarr=new uint[](k);
         string[] memory Status=new string[](k);
         string[] memory unit=new string[](k);
         for(i=0;i<k;i++){
            
                    Rarr[i]=ReqMap[mDDST[_email].DDSTtoASC[i]].items;
                    Qarr[i]=ReqMap[mDDST[_email].DDSTtoASC[i]].quantity;
                    Timestamps[i]=ReqMap[mDDST[_email].DDSTtoASC[i]].tx.timestamp;
                    Status[i]=ReqMap[mDDST[_email].DDSTtoASC[i]].status;
                    Idarr[i]=mDDST[_email].DDSTtoASC[i];
                    unit[i]=ReqMap[mDDST[_email].DDSTtoASC[i]].unit_email;
            
         }
         return ([Rarr,Qarr,Status],Idarr,Timestamps,unit);
     }
     function getSentToDivisions(string memory DGST_email)public view returns(uint[] memory){
         return mDGST[DGST_email].DGSTtoDivisions;
     }
     function sendToDivisions(uint id,string memory dgst_email)public{
         ReqMap[id].tracking.push(string.concat("sent to Divisions from DGST :",dgst_email));
           ReqMap[id].trackingTimeStamp.push(block.timestamp);
         mDGST[dgst_email].DGSTtoDivisions.push(id);
     }
     function getAcceptedFromDgst(string memory ddst_email)public view returns(uint[] memory){
         return mDDST[ddst_email].AcceptedDGSTRequest;

     }
     function getAcceptedByDgst(string memory dgst_email,string memory ddst_email)public view returns(uint[] memory,uint[] memory){
         return (mDGST[dgst_email].Accepted,mDDST[ddst_email].Accepted);

     }
     

     function DGSTaccept(uint id,string memory dgst_email,string memory ddst_email)public {
         
         ReqMap[id].status="accepted";
         ReqMap[id].tracking.push(string.concat("Accepted by :",dgst_email));
           ReqMap[id].trackingTimeStamp.push(block.timestamp);
         ReqMap[id].Acceptedby=dgst_email;
         mDDST[ddst_email].Accepted.push(id);
         mDGST[dgst_email].Accepted.push(id);
         uint i;
         for(i=0;i<mDDST[ddst_email].DDSTtoASC.length;i++){
             if(mDDST[ddst_email].DDSTtoASC[i]==id){

                 
                 mDDST[ddst_email].DDSTtoASC[i]=mDDST[ddst_email].DDSTtoASC[mDDST[ddst_email].DDSTtoASC.length-1];
                 mDDST[ddst_email].DDSTtoASC[mDDST[ddst_email].DDSTtoASC.length-1]=id;
                 mDDST[ddst_email].DDSTtoASC.pop();
                 break;
             }
         }
         
     }
     function myDGST(string memory ddst_email)public view returns(string memory,uint[] memory){
         return (mDDST[ddst_email].ourDGST,mDDST[ddst_email].DDSTtoASC);
     }
     function DDGSTinfo(string memory ddst_email)public view returns(string memory,uint[] memory){
         return (mDDST[ddst_email].ourDGST,mDGST[mDDST[ddst_email].ourDGST].DGSTtoDivisions);
     }
     function DGSTacceptedbyDDST(string memory ddst_email)public view returns(uint[] memory){
         return (mDDST[mDDST[ddst_email].ourDGST].AcceptedDGSTRequest);
     }
     function getCurrentId()public view returns(uint){
         return requestId;
     }
     
}


