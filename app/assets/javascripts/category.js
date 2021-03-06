$(function(){
  // カテゴリーセレクトボックスのオプション（選択肢）を作成
  function appendOption(category){
    var html = `<option value="${category.id}" data-category="${category.id}">${category.name}</option>`;
    return html;
  }
  // 子カテゴリーの表示作成
  function appendChildrenBox(insertHTML){
    var childSelectHtml = '';
    childSelectHtml =`<div class='selling-body__form__field__category__child' id= 'child_wrapper'>
                        <select class="selling-body__form__field__category__child--select" id="child_category" name="">
                          <option value="---" data-category="---">選択してください</option>
                          ${insertHTML}
                        <select>
                      </div>`;
    $('.selling-body__form__field__category').append(childSelectHtml);
  }

  // // 孫カテゴリーの表示作成
  function appendGrandchildrenBox(insertHTML){
    var grandchildSelectHtml = '';
    grandchildSelectHtml = `<div class='selling-body__form__field__category__grandchild' id= 'grandchild_wrapper'>
                              <select class="selling-body__form__field__category__grandchild--select" id="grandchild_category" name="item[category_id]">
                                <option value="---" data-category="---">選択してください</option>
                                ${insertHTML}
                              </select>
                            </div>`;
    $('#child_wrapper').append(grandchildSelectHtml);
  }

  // 親カテゴリー選択後のイベント
  $('#parent_category').on('change', function(){
    var parent_category_id = document.getElementById
    ('parent_category').value; //選択された親カテゴリーの名前を取得
    if (parent_category_id != ""){ 
      $.ajax({
        url: '/items/category/get_category_children',
        type: 'GET',
        data: { parent_id: parent_category_id },
        dataType: 'json'
      })
      .done(function(children){
        $('#child_wrapper').remove(); //親が変更された時、子以下を削除
        $('#grandchild_wrapper').remove();
        var insertHTML = '';
        children.forEach(function(child){
          insertHTML += appendOption(child);
        });
        appendChildrenBox(insertHTML);
      })
      .fail(function(){
        alert('カテゴリー取得に失敗しました');
      })
    }else{
      $('#child_wrapper').remove(); //親カテゴリーが初期値になった時、子以下を削除
      $('#grandchild_wrapper').remove();
    }
  });

  // 子カテゴリー選択後のイベント
  $('.selling-body__form__field__category').on('change', '#child_category', function(){
    
    var child_category_id = $(this).val();
    if (child_category_id != "---"){ 
      $.ajax({
        url: '/items/category/get_category_grandchildren',
        type: 'GET',
        data: { child_id: child_category_id },
        dataType: 'json'
      })
      .done(function(grandchildren){
        if (grandchildren.length != 0) {
          $('#grandchild_wrapper').remove(); //子が変更された時、孫以下を削除
          var insertHTML = '';
          grandchildren.forEach(function(grandchild){
            insertHTML += appendOption(grandchild);
          });
          appendGrandchildrenBox(insertHTML);
        }
      })
      .fail(function(){
        alert('カテゴリー取得に失敗しました');
      })
    }else{
      $('#grandchild_wrapper').remove(); //子カテゴリーが初期値になった時、孫以下を削除
    }
  });
});