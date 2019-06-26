import React from 'react';
import { SelectInput, Edit, TextInput, TabbedForm, FormTab, DateInput, TextField , List, Datagrid, Toolbar, SaveButton} from 'react-admin';
import RichTextInput from 'ra-input-rich-text';

const headerStyle= {
    backgroundColor: "#2196f3",
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
            <TextField source="id" name="Unit of Analysis" />
            <TextField source="Progress" />
        </Datagrid>
    </List>
);

export const PostEdit = (props) => (
    <Edit title={<PostTitle />} undoable={false} {...props}>
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
