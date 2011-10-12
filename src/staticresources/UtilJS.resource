function confirmCancel() {
   var isCancel = confirm("Are you sure you wish to cancel?");
   if (isCancel) return true;

   return false;
}