import bottle
import pymongo
import bcrypt
from beaker.middleware import SessionMiddleware
from bottle import route, template, request, redirect, abort
import bson
from bson import json_util
import datetime

session_opts = {
        'session.type': 'file',
        'session.cookie_expires': 86400,
        'session.data_dir': './sessions',
        'session.auto': True
        }
app = SessionMiddleware(bottle.app(), session_opts)

def get_db():
    return pymongo.Connection('mongodb://localhost').juicenb

def get_session():
    return request.environ.get('beaker.session')

@route('/js/<filename:path>')
def send_css(filename):
    return bottle.static_file(filename, root='js')

@route('/css/<filename:path>')
def send_css(filename):
    return bottle.static_file(filename, root='css')

@route('/favicon.ico')
def favicon():
    bottle.abort(404)

@route('/')
def index():
    session = get_session()
    if not session.has_key('username'):
        return template("index")
    else:
        redirect('/notebook')

@route('/auth', method='POST')
def auth():
    if 'username' in get_session():
        del get_session()['username']
    login_name = request.forms.login_name
    password = request.forms.password
    db = get_db()
    user = db.users.find_one({'_id':login_name})
    if not user:
        user = db.users.find_one({'email':login_name})
    if user:
        if user['pw_hash'] == bcrypt.hashpw(password, user['pw_hash']):
            get_session()['username'] = user['_id']
    redirect('/')

@route('/users', method='POST')
def add_users():
    username = request.forms.username.strip()
    password = request.forms.password.strip()
    email = request.forms.email.strip()
    if username and password and email:
        db = get_db()
        user = db.users.find_one({'_id':username})
        if not user:
            user = {'_id':username,
                    'email':email,
                    'pw_hash':bcrypt.hashpw(password, bcrypt.gensalt())
                    }
            db.users.insert(user)
            session = get_session()
            session['username'] = username
    redirect('/')

@route('/notebook')
@route('/notebook/main')
def notebook():
    session = get_session()
    if not session.has_key('username'):
        redirect('/')
    db = get_db()
    flavor_records = db.flavors.find({'username':session['username']})
    flavors = [f for f in flavor_records]
    recipe_records = db.recipes.find({'username':session['username']})
    recipes = [r for r in recipe_records]
    return template('notebook.main',username=session['username'],flavors=flavors, recipes=recipes)

@route('/notebook/recipes/<oid>')
def get_recipe(oid):
    session = get_session()
    if 'username' not in session:
        abort(404)
        return
    db = get_db()
    recipe_record = db.recipes.find_one({"_id":bson.ObjectId(oid),'username':session['username']})
    if recipe_record:
        return json_util.dumps(recipe_record)
    else:
        abort(404)

@route('/notebook/recipes/<oid>', method='POST')
def update_recipe(oid):
    session = get_session()
    if 'username' not in session:
        abort(404)
        return
    db = get_db()
    recipe_record = db.recipes.find_one({"_id":bson.ObjectId(oid),'username':session['username']})
    if recipe_record:
        recipe_name = request.forms.edit_recipe_name.strip()
        notes = request.forms.edit_recipe_notes.strip()
        flavor_1 = request.forms.edit_flavor_1.strip()
        flavor_1_percent = request.forms.edit_flavor_1_percent.strip()
        flavor_2 = request.forms.edit_flavor_2.strip()
        flavor_2_percent = request.forms.edit_flavor_2_percent.strip()
        flavor_3 = request.forms.edit_flavor_3.strip()
        flavor_3_percent = request.forms.edit_flavor_3_percent.strip()
        if recipe_name:
            print request.forms.keys()
            recipe_record['name'] = recipe_name
            recipe_record['notes'] = notes
            recipe_record['components'] = []
            if flavor_1_percent.isdigit():
                recipe_record['components'].append({'flavor':flavor_1,'percent':flavor_1_percent})
            if flavor_2_percent.isdigit():
                recipe_record['components'].append({'flavor':flavor_2,'percent':flavor_2_percent})
            if flavor_3_percent.isdigit():
                recipe_record['components'].append({'flavor':flavor_3,'percent':flavor_3_percent})

            if len(recipe_record['components']) > 0:
                db = get_db()
                db.recipes.save(recipe_record)
    redirect('/notebook')

def get_next_batch_id():
    db = get_db()
    username = get_session()['username']
    return 'BAT-'+str(db.users.find_and_modify(
        query={
            '_id':username
        },
        fields={
            'batch_seq':1
        },
        update={
            '$inc':{'batch_seq':1}
        },
        new=True
    )['batch_seq'])

def get_next_recipe_id():
    db = get_db()
    username = get_session()['username']
    return 'REC-'+str(db.users.find_and_modify(
        query={
            '_id':username
        },
        fields={
            'recipe_seq':1
        },
        update={
            '$inc':{'recipe_seq':1}
        },
        new=True
    )['recipe_seq'])


@route('/notebook/recipes/<oid>/batches', method='GET')
def new_batch(oid):
    session = get_session()
    if 'username' not in session:
        abort(404)
        return
    db = get_db()
    batches = db.batches.find({"recipe":oid,'username':session['username']})
    return json_util.dumps(batches)

@route('/notebook/recipes/<oid>/batches', method='POST')
def new_batch(oid):
    session = get_session()
    if 'username' not in session:
        redirect('/')
    batch_size = request.forms.new_batch_size
    notes = request.forms.new_batch_notes.strip()
    if batch_size:
        batch = {'username':session['username'],'batch_size':batch_size,'notes':notes}
        db = get_db()
        batch['code'] = get_next_batch_id()
        batch['batch_date'] = datetime.datetime.utcnow()
        batch['recipe'] = oid
        db.batches.insert(batch)
    redirect('/notebook')

@route('/notebook/recipes', method='POST')
def new_recipe():
    session = get_session()
    if 'username' not in session:
        redirect('/')
    recipe_name = request.forms.recipe_name
    notes = request.forms.new_recipe_notes.strip()
    flavor_1 = request.forms.flavor_1
    flavor_1_percent = request.forms.flavor_1_percent.strip()
    flavor_2 = request.forms.flavor_2
    flavor_2_percent = request.forms.flavor_2_percent.strip()
    flavor_3 = request.forms.flavor_3
    flavor_3_percent = request.forms.flavor_3_percent.strip()
    if recipe_name:
        recipe = {'username':session['username'],'name':recipe_name,'notes':notes,'components':[]}
        if flavor_1_percent.isdigit():
            recipe['components'].append({'flavor':flavor_1,'percent':flavor_1_percent})
        if flavor_2_percent.isdigit():
            recipe['components'].append({'flavor':flavor_2,'percent':flavor_2_percent})
        if flavor_3_percent.isdigit():
            recipe['components'].append({'flavor':flavor_3,'percent':flavor_3_percent})

        if len(recipe['components']) > 0:
            db = get_db()
            recipe['code'] = get_next_recipe_id()
            db.recipes.insert(recipe)
    redirect('/notebook')

@route('/notebook/flavors/<oid>')
def get_flavor(oid):
    session = get_session()
    if 'username' not in session:
        abort(404)
        return
    db = get_db()
    flavor_record = db.flavors.find_one({"_id":bson.ObjectId(oid),'username':session['username']})
    if flavor_record:
        return json_util.dumps(flavor_record)
    else:
        abort(404)
        return "Flavor not found"
    

@route('/notebook/flavors/<oid>', method='POST')
def update_flavor(oid):
    session = get_session()
    if 'username' not in session:
        abort(404)
        return
    db = get_db()
    flavor_record = db.flavors.find_one({"_id":bson.ObjectId(oid),'username':session['username']})
    if flavor_record:
        flavor_record['flavor'] = request.forms.edit_flavor.strip()
        flavor_record['supplier'] = request.forms.edit_flavor_supplier.strip()
        flavor_record['brand'] = request.forms.edit_flavor_brand.strip()
        flavor_record['notes'] = request.forms.edit_flavor_notes.strip()
        db.flavors.save(flavor_record)
    redirect('/notebook')

@route('/notebook/flavors', method='POST')
def new_flavor():
    session = get_session()
    if not session.has_key('username'):
        redirect('/')

    flavor = request.forms.new_flavor.strip()
    supplier = request.forms.new_flavor_supplier.strip()
    brand = request.forms.new_flavor_brand.strip()
    notes = request.forms.new_flavor_notes.strip()
    if flavor:
        flavor_record = {'username':session['username'],'flavor':flavor,'supplier':supplier,'brand':brand,'notes':notes}
        db = get_db()
        db.flavors.insert(flavor_record)
    redirect('/notebook')

if __name__ == '__main__':
    bottle.run(app=app, host='localhost', port='8080', reloader=True, debug=True)

