import React from 'react';
import { SelectInput, Edit, TextInput, TabbedForm, FormTab, DateInput, TextField , List, Datagrid} from 'react-admin';
import RichTextInput from 'ra-input-rich-text';

const headerStyle= {
    backgroundColor: "#4682b4",
    padding: "0.5px 15px",
    color: "white"
};

const PostTitle = ({ record }) => {
    return <span>Post {record ? `"${record.title}"` : ''}</span>;
};

const Header = ({ header, caption }) => {
    return(<div style={headerStyle}><h2>{header}</h2><h4>{caption}</h4></div>);
}

export const PostList = props => (
    <List {...props}>
        <Datagrid rowClick="edit">
            <TextField source="id" />
        </Datagrid>
    </List>
);

export const PostEdit = (props) => (
    <Edit title={<PostTitle />} {...props}>
        <TabbedForm>
            <FormTab label="Coding">
                XXXXX
            </FormTab>
            <FormTab label="Notes">
                <RichTextInput source="body" />
            </FormTab>
        </TabbedForm>
    </Edit>
);
