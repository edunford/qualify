import React from 'react';
import { AppBar } from 'react-admin';
import { withStyles } from '@material-ui/core/styles';
import Typography from '@material-ui/core/Typography';

const styles = {
    title: {
        flex: 1,
        textOverflow: 'ellipsis',
        whiteSpace: 'nowrap',
        overflow: 'hidden',
    },
    spacer: {
        flex: 1,
    },
    a: {
        textDecoration: 'none'
    }
};

const MyAppBar = withStyles(styles)(({ classes, ...props }) => (
    <AppBar {...props}>

        <span className={classes.spacer} />
    </AppBar>
));

export default MyAppBar;