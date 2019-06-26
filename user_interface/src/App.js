import React from 'react';
import { Admin, Resource, ListGuesser } from 'react-admin';
import jsonServerProvider from 'ra-data-json-server';

import { PostEdit, PostList } from './posts_compiled';

const App = () => (
    <Admin dataProvider={jsonServerProvider('http://localhost:8000')}>
        <Resource name="posts" list={PostList} edit={PostEdit} />
    </Admin>
);

export default App;
