import React from 'react';
import { Layout, Sidebar } from 'react-admin';
import MyMenu from './CustomMenu';
import MyAppBar from './CustomBar';

const MySidebar = props => <Sidebar {...props} size={20} />;
const MyLayout = props => <Layout
    {...props}
    menu={MyMenu}
    appBar={MyAppBar}
    sidebar={MySidebar}
/>;

export default MyLayout;