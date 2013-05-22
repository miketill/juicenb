<!DOCTYPE html>
<html>
    <head>
        <title>Juice Notebook - {{username}}</title>
        <link href="/css/bootstrap.min.css" rel="stylesheet" media="screen">
        <script src="/js/jquery-1.9.0.min.js"></script>
        <script src="/js/bootstrap.min.js"></script>
        <script>
            function edit_flavor(oid) {
                $.getJSON('/notebook/flavors/'+oid, function(data) {
                    $('#edit_flavor_form')[0].reset();
                    $('#edit_flavor_form').attr('action','/notebook/flavors/'+oid);
                    $('#edit_flavor_brand').val(data.brand);
                    $('#edit_flavor_supplier').val(data.supplier);
                    $('#edit_flavor_notes').val(data.notes);
                    $('#edit_flavor').val(data.flavor);
                    $('#m_edit_flavoring').modal('toggle');
                });
            }

            function edit_recipe(oid) {
                $.getJSON('/notebook/recipes/'+oid, function(data) {
                    $('#edit_recipe_form')[0].reset();
                    $('#edit_recipe_form').attr('action','/notebook/recipes/'+oid);
                    $('#edit_recipe_form_oid').val(oid);
                    $('#edit_recipe_name').val(data.name);
                    //alert(data.components.length)
                    for (var i = 0; i < data.components.length; i++) {
                        //alert('#edit_flavor_'+(i+1))
                        $('#edit_flavor_'+(i+1)).val(data.components[i].flavor);
                        $('#edit_flavor_'+(i+1)+'_percent').val(data.components[i].percent);
                    }
                    $('#edit_recipe_notes').val(data.notes);
                    $('#m_edit_recipe').modal('toggle');
                });
            }

            function new_batch(oid) {
                $('#m_edit_recipe').modal('toggle');
                var oid = $('#edit_recipe_form_oid').val();
                $('#add_batch_form').attr('action','/notebook/recipes/'+oid+'/batches');
                $('#add_batch_recipe_name').val($("#edit_recipe_name").val());
                $('#m_add_batch').modal('toggle');
            }
        </script>
    </head>
    <body>
        <div class='container'>
            <div class='navbar'>
                <div class='navbar-inner'>
                    <a class='brand' href='#'>Actions</a>
                    <ul class='nav'>
                        <li><a href='#' data-toggle='modal' data-target='#m_add_flavoring'>Add Flavoring</a>
                        <li><a href='#' data-toggle='modal' data-target='#m_add_recipe'>Add Recipe</a>
                    </ul>
                </div>
            </div>
            <table class='table table-hover table-condensed'>
                <caption>Flavors</caption>
                <thead>
                    <tr>
                        <th>Flavor</th>
                        <th>Brand</th>
                        <th>Supplier</th>
			<th>Amount (ml)</th>
                        <th>Notes</th>
                    </tr>
                </thead>
                <tbody>
                    %for f in flavors:
                        <tr onclick='edit_flavor("{{f['_id']}}")'>
                            <td>{{f['flavor']}}</td>
                            <td>{{f['brand']}}</td>
                            <td>{{f['supplier']}}</td>
                            <td>{{f['stock']}}</td>
                            <td>{{f['notes']}}</td>
                        </tr>
                    %end
                </tbody>
            </table>
            <table class='table table-hover table-condensed'>
                <caption>Recipes</caption>
                <thead>
                    <tr>
                        <th>Code</th>
                        <th>Name</th>
                        <th>Flavor</th>
                        <th>Flavor</th>
                        <th>Flavor</th>
                        <th>Notes</th>
                    </tr>
                </thead>
                <tbody>
                    %for r in recipes:
                        <tr onclick='edit_recipe("{{r['_id']}}")'>
                            <td>{{r['code']}}</td>
                            <td>{{r['name']}}</td>
                            <td>{{r['components'][0]['flavor']}} @ {{r['components'][0]['percent']}}%</td>
                            %if len(r['components']) > 1:
                                <td>{{r['components'][1]['flavor']}} @ {{r['components'][1]['percent']}}%</td>
                                %if len(r['components']) > 2:
                                    <td>{{r['components'][2]['flavor']}} @ {{r['components'][2]['percent']}}%</td>
                                %else:
                                    <td>&nbsp;</td>
                                %end
                            %else:
                                <td colspan='2'>&nbsp;</td>
                            %end
                            <td>{{r['notes']}}</td>
                        </tr>
                    %end
                </tbody>
            </table>
            <div class='row'>
                <div class='span1'>
                    x
                </div>
                <div class='span1'>
                    x
                </div>
                <div class='span1'>
                    x
                </div>
                <div class='span1'>
                    x
                </div>
                <div class='span1'>
                    x
                </div>
                <div class='span1'>
                    x
                </div>
                <div class='span1'>
                    x
                </div>
                <div class='span1'>
                    x
                </div>
                <div class='span1'>
                    x
                </div>
                <div class='span1'>
                    x
                </div>
                <div class='span1'>
                    x
                </div>
                <div class='span1'>
                    x
                </div>
            </div>
        </div>
        <div id='m_edit_flavoring' class='modal hide fade' tabindex='-1' role='dialog'>
            <form id='edit_flavor_form' action='/notebook/flavors' method='POST'>
                <input type='hidden' name='edit_flavor_oid' value=''>
                <div class='modal-header'>
                    <h3>Edit Flavoring</h3>
                </div>
                <div class='modal-body'>
                    <label for='edit_flavor_brand'>Brand</label><input id='edit_flavor_brand' name='edit_flavor_brand' placeholder='e.g., The Flavor Apprentice'>
                    <label for='edit_flavor_supplier'>Supplier</label><input id='edit_flavor_supplier' name='edit_flavor_supplier' placeholder='e.g., Wizard Labs'>
                    <label for='edit_flavor'>Flavor</label><input id='edit_flavor' name='edit_flavor' placeholder='e.g., Fruit Blast'>
                    <label for='edit_flavor_stock'>Amount (ml)</label><input id='edit_flavor_stock' name='edit_flavor_stock' placeholder='42'>
                    <label for='edit_flavor_notes'>Notes</label><textarea rows='5' name='edit_flavor_notes' id='edit_flavor_notes' placeholder='Notes on this flavoring'></textarea>
                </div>
                <div class='modal-footer'>
                    <button type='button' class='btn' data-dismiss='modal'>Cancel</button>
                    <button type='submit' class='btn btn-primary'>Update Flavoring</button>
                </div>
            </form>
        </div>
        <div id='m_add_flavoring' class='modal hide fade' tabindex='-1' role='dialog'>
            <form action='/notebook/flavors' method='POST'>
                <div class='modal-header'>
                    <h3>Add Flavoring</h3>
                </div>
                <div class='modal-body'>
                    <label for='new_flavor_brand'>Brand</label><input id='new_flavor_brand' name='new_flavor_brand' placeholder='e.g., The Flavor Apprentice'>
                    <label for='new_flavor_supplier'>Supplier</label><input id='new_flavor_supplier' name='new_flavor_supplier' placeholder='e.g., Wizard Labs'>
                    <label for='new_flavor'>Flavor</label><input id='new_flavor' name='new_flavor' placeholder='e.g., Fruit Blast'>
                    <label for='edit_flavor_stock'>Amount (ml)</label><input id='edit_flavor_stock' name='edit_flavor_stock' placeholder='42'>
                    <label for='new_flavor_notes'>Notes</label><textarea rows='5' name='new_flavor_notes' placeholder='Notes on this flavoring'></textarea>
                </div>
                <div class='modal-footer'>
                    <button type='button' class='btn' data-dismiss='modal'>Cancel</button>
                    <button type='submit' class='btn btn-primary'>Add Flavoring</button>
                </div>
            </form>
        </div>
        <div id='m_add_recipe' class='modal hide fade' tabindex='-1' role='dialog'>
            <form class='form-horizontal' action='/notebook/recipes' method='POST'>
                <div class='modal-header'>
                    <h3>Add Recipe</h3>
                </div>
                <div class='modal-body'>
                    <div class='control-group'>
                        <div class='controls'>
                            <input type='text' name='recipe_name' placeholder='Name of recipe'>
                        </div>
                    </div>
                    <div class='control-group'>
                        <label for='flavor_1' class='control-label'>Flavor 1</label>
                        <div class='controls'>
                            <select id='flavor_1' class='input-medium' name='flavor_1'>
                                %for f in flavors:
                                <option value='{{f['flavor']}}'>{{f['flavor']}}</option>
                                %end
                            </select>
                            <div class='input-append'>
                                <input type='text' class='input-mini' name='flavor_1_percent'><span class='add-on'>%</span>
                            </div>
                        </div>
                    </div>
                    <div class='control-group'>
                        <label for='flavor_2' class='control-label'>Flavor 2</label>
                        <div class='controls'>
                            <select id='flavor_2' class='input-medium' name='flavor_2'>
                                %for f in flavors:
                                <option value='{{f['flavor']}}'>{{f['flavor']}}</option>
                                %end
                            </select>
                            <div class='input-append'>
                                <input type='text' class='input-mini' name='flavor_2_percent'><span class='add-on'>%</span>
                            </div>
                        </div>
                    </div>
                    <div class='control-group'>
                        <label for='flavor_3' class='control-label'>Flavor 3</label>
                        <div class='controls'>
                            <select id='flavor_3' class='input-medium' name='flavor_3'>
                                %for f in flavors:
                                <option value='{{f['flavor']}}'>{{f['flavor']}}</option>
                                %end
                            </select>
                            <div class='input-append'>
                                <input type='text' class='input-mini' name='flavor_3_percent'><span class='add-on'>%</span>
                            </div>
                        </div>
                    </div>
                    <div class='control-group'>
                        <label for='new_recipe_notes' class='control-label'>Notes</label>
                        <div class='controls'>
                            <textarea rows='5' name='new_recipe_notes' placeholder='Notes on this recipe'></textarea>
                        </div>
                    </div>
                </div>
                <div class='modal-footer'>
                    <button type='button' class='btn' data-dismiss='modal'>Cancel</button>
                    <button type='submit' class='btn btn-primary'>Add Recipe</button>
                </div>
            </form>
        </div>
        <div id='m_edit_recipe' class='modal hide fade' tabindex='-1' role='dialog'>
            <form class='form-horizontal' id='edit_recipe_form' action='/notebook/recipes' method='POST'>
                <input type='hidden' id='edit_recipe_form_oid'>
                <div class='modal-header'>
                    <h3>Edit Recipe</h3>
                </div>
                <div class='modal-body'>
                    <div class='control-group'>
                        <div class='controls'>
                            <input type='text' id='edit_recipe_name' name='edit_recipe_name' placeholder='Name of recipe'>
                        </div>
                    </div>
                    <div class='control-group'>
                        <label for='edit_flavor_1' class='control-label'>Flavor 1</label>
                        <div class='controls'>
                            <select id='edit_flavor_1' class='input-medium' name='edit_flavor_1'>
                                %for f in flavors:
                                <option value='{{f['flavor']}}'>{{f['flavor']}}</option>
                                %end
                            </select>
                            <div class='input-append'>
                                <input type='text' class='input-mini' id='edit_flavor_1_percent' name='edit_flavor_1_percent'><span class='add-on'>%</span>
                            </div>
                        </div>
                    </div>
                    <div class='control-group'>
                        <label for='edit_flavor_2' class='control-label'>Flavor 2</label>
                        <div class='controls'>
                            <select id='edit_flavor_2' class='input-medium' name='edit_flavor_2'>
                                %for f in flavors:
                                <option value='{{f['flavor']}}'>{{f['flavor']}}</option>
                                %end
                            </select>
                            <div class='input-append'>
                                <input type='text' class='input-mini' id='edit_flavor_2_percent' name='edit_flavor_2_percent'><span class='add-on'>%</span>
                            </div>
                        </div>
                    </div>
                    <div class='control-group'>
                        <label for='edit_flavor_3' class='control-label'>Flavor 3</label>
                        <div class='controls'>
                            <select id='edit_flavor_3' class='input-medium' name='edit_flavor_3'>
                                %for f in flavors:
                                <option value='{{f['flavor']}}'>{{f['flavor']}}</option>
                                %end
                            </select>
                            <div class='input-append'>
                                <input type='text' class='input-mini' id='edit_flavor_3_percent' name='edit_flavor_3_percent'><span class='add-on'>%</span>
                            </div>
                        </div>
                    </div>
                    <div class='control-group'>
                        <label for='edit_recipe_notes' class='control-label'>Notes</label>
                        <div class='controls'>
                            <textarea rows='5' id='edit_recipe_notes' name='edit_recipe_notes' placeholder='Notes on this recipe'></textarea>
                        </div>
                    </div>
                </div>
                <div class='modal-footer'>
                    <button type='button' class='btn' onclick='new_batch("")'>Create Batch</button>
                    <button type='button' class='btn' data-dismiss='modal'>Cancel</button>
                    <button type='submit' class='btn btn-primary'>Update Recipe</button>
                </div>
            </form>
        </div>


        <div id='m_add_batch' class='modal hide fade' tabindex='-1' role='dialog'>
            <form class='form-horizontal' id='add_batch_form' action='/notebook/recipes' method='POST'>
                <div class='modal-header'>
                    <h3>Add Batch</h3>
                </div>
                <div class='modal-body'>
                    <div class='control-group'>
                        <div class='controls'>
                            <input type='text' id='add_batch_recipe_name' placeholder='Name of recipe' readonly>
                        </div>
                    </div>
                    <div class='control-group'>
                        <label for='new_batch_size' class='control-label'>Amount</label>
                        <div class='controls'>
                            <input type='text' id='new_batch_size' name='new_batch_size' placeholder='Batch Amount'>
                        </div>
                    </div>
                    <div class='control-group'>
                        <label for='new_batch_notes' class='control-label'>Notes</label>
                        <div class='controls'>
                            <textarea rows='5' name='new_batch_notes' placeholder='Notes on this batch'></textarea>
                        </div>
                    </div>
                </div>
                <div class='modal-footer'>
                    <button type='button' class='btn' data-dismiss='modal'>Cancel</button>
                    <button type='submit' class='btn btn-primary'>Add Batch</button>
                </div>
            </form>
        </div>
    </body>
</html>
